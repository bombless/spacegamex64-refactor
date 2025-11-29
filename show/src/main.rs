use glium::{Display, Surface, uniform};
use std::fs;

fn source(path: &str) -> Vec<u8> {
    let content = fs::read_to_string(path).unwrap();
    let mut result = Vec::new();

    for line in content.lines() {
        let after_db = line.split("db ").nth(1).unwrap_or("");
        for item in after_db.split(',') {
            let trimmed = item.trim();
            if trimmed.len() >= 4 {
                let c1 = trimmed.chars().nth(1).unwrap();
                let c2 = trimmed.chars().nth(2).unwrap();
                if let (Some(v1), Some(v2)) = (c1.to_digit(16), c2.to_digit(16)) {
                    result.push((v1 * 16 + v2) as u8);
                }
            }
        }
    }
    result
}

fn get_image(n: usize, data: &[u8]) -> Vec<u8> {
    let mut img = Vec::new();
    let offset = n * 32 * 32 * 4;
    for i in 0 .. 32 {
        for j in 0 .. 32 {
            let idx = offset + (i * 32 + j) * 4;
            img.extend_from_slice(&[data[idx + 2], data[idx + 1], data[idx]]);
        }
    }
    img
}

struct TileMap {
    raw: Vec<u8>,
    map: Vec<usize>,
    map_width: usize,   // 地图宽度（tile 数）
    map_height: usize,  // 地图高度（tile 数）
    tile_size: usize,   // 每个 tile 的像素大小
}

impl TileMap {
    fn new() -> Self {
        let raw = source("../graphics/bgTiles.inc");
        let map_source = source("../graphics/tilemap.inc");
        
        let mut map = Vec::new();
        for i in 0..map_source.len() / 2 {
            let lo = map_source[i * 2] as usize;
            let hi = map_source[i * 2 + 1] as usize;
            let n = lo + (hi << 8);
            map.push(n);
        }
        
        // 根据汇编：15 列 × 20 行
        Self {
            raw,
            map,
            map_width: 15,
            map_height: 20,
            tile_size: 8,  // 假设 8×8 像素
        }
    }

    fn get_color(&self, x: usize, y: usize) -> Option<(u8, u8, u8)> {
        let tile_x = x / self.tile_size;
        let tile_y = y / self.tile_size;
        
        // 边界检查
        if tile_x >= self.map_width || tile_y >= self.map_height {
            return None;
        }
        
        // 计算 tile 索引（行优先）
        let tile_idx = tile_y * self.map_width + tile_x;
        let tile_id = self.map[tile_idx];
        
        // tile 数据偏移（每个 tile = 8×8 像素 × 4 字节）
        let bytes_per_tile = self.tile_size * self.tile_size * 4;
        let offset = tile_id * bytes_per_tile;
        
        // tile 内的像素位置
        let px = x % self.tile_size;
        let py = y % self.tile_size;
        
        // 像素在 tile 内的偏移
        // 注意：你原来用 7-x%8，这是水平翻转，需要确认是否需要
        let pixel_offset = (py * self.tile_size + px) * 4;
        
        let buffer = &self.raw[offset + pixel_offset..];
        Some((buffer[2], buffer[1], buffer[0]))  // BGR -> RGB
    }
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1. 解析成 Vec<u8>
    let tiles = source("../graphics/spriteTiles.inc");
    let tiles2 = source("../graphics/spriteTiles2.inc");
    let bg_tiles = TileMap::new();

    // 2. 取 rgb 数据
    let mut rgb = Vec::<u8>::new();

    for y in 0 .. 32 * 8 * 2 {
        let is_extra_space = y < 32 * 8;
        let y = 32 * 8 - 1 - y % (32 * 8);
        for x in 0 .. 32 * 8 * 2 {
            if is_extra_space {
                if x >= 32 * 8 {
                    rgb.extend(&[0, 0, 0]);
                    continue;                    
                }
                let color = bg_tiles.get_color(x, y).unwrap_or((0, 0, 0));
                rgb.extend(&[color.0, color.1, color.2]);
                continue;
            }
            let tiles = if x < 32 * 8 { &tiles } else { &tiles2 };
            let i = x % (32 * 8) / 32;
            let j = y % (32 * 8) / 32;
            let n = i * 8 + j;
            let data = get_image(n, tiles);
            let offset = y % 32 * 32 * 3 + x  % 32 * 3;
            rgb.extend(&[data[offset], data[offset + 1], data[offset + 2]]);
        }
    }


    // 3. 创建窗口
    let event_loop = glium::glutin::event_loop::EventLoop::new();
    let wb = glium::glutin::window::WindowBuilder::new()
                .with_title("inc 图片")
                .with_inner_size(glium::glutin::dpi::LogicalSize::new(512, 512));
    let cb = glium::glutin::ContextBuilder::new();
    let display = Display::new(wb, cb, &event_loop)?;

    // 4. 把 rgb 数据做成纹理
    let image = glium::texture::RawImage2d {
        data: std::borrow::Cow::Borrowed(&rgb),
        width: 32 * 8 * 2,
        height: 32 * 8 * 2,
        format: glium::texture::ClientFormat::U8U8U8,
    };
    let texture = glium::texture::Texture2d::new(&display, image)?;

    // 5. 简单全屏三角形 + 纹理着色器
    let vertices = [
        Vertex { pos: [-1.0, -1.0], tex: [0.0, 0.0] },
        Vertex { pos: [ 1.0, -1.0], tex: [1.0, 0.0] },
        Vertex { pos: [-1.0,  1.0], tex: [0.0, 1.0] },
        Vertex { pos: [ 1.0,  1.0], tex: [1.0, 1.0] },
    ];
    let indices = glium::index::NoIndices(glium::index::PrimitiveType::TriangleStrip);

    let vertex_buffer = glium::VertexBuffer::new(&display, &vertices)?;
    let program = glium::Program::from_source(&display,
        // vertex
        "#version 140
        in vec2 pos;
        in vec2 tex;
        out vec2 v_tex;
        void main() {
            gl_Position = vec4(pos, 0.0, 1.0);
            v_tex = tex;
        }",
        // fragment
        "#version 140
        in vec2 v_tex;
        out vec4 color;
        uniform sampler2D tex;
        void main() {
            color = vec4(texture(tex, v_tex).rgb, 1.0);
        }",
        None
    )?;

    // 6. 主循环
    use glium::glutin::event::{Event, WindowEvent};
    use glium::glutin::event_loop::ControlFlow;

    event_loop.run(move |ev, _, cf| {
        *cf = ControlFlow::Wait;

        if let Event::WindowEvent { event: WindowEvent::CloseRequested, .. } = ev {
            *cf = ControlFlow::Exit;
            return;
        }

        let mut frame = display.draw();
        frame.clear_color(0.1, 0.1, 0.1, 1.0);
        frame.draw(&vertex_buffer, &indices, &program,
                   &uniform!{ tex: &texture },
                   &Default::default()).unwrap();
        frame.finish().unwrap();
    });
}

#[derive(Copy, Clone)]
struct Vertex {
    pos: [f32; 2],
    tex: [f32; 2],
}
glium::implement_vertex!(Vertex, pos, tex);