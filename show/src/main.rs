use glium::{Display, Surface, uniform};
use std::fs;
use glium::backend::glutin::SimpleWindowBuilder;
use winit::application::ApplicationHandler;
use glutin::surface::WindowSurface;
use winit::window::{WindowId, Window};
use winit::event_loop::{ActiveEventLoop, ControlFlow};
use winit::event::WindowEvent;
use std::time::Instant;

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
    raw: Vec<u8>,           // tile 图形数据 (bgTiles)
    map: Vec<u16>,          // 完整地图数据（只读源）
    vram: Vec<u16>,         // TILEMAP0 的模拟（32x32 工作区）
    tile_size: usize,       // 每个 tile 的像素大小 = 8
    
    // 滚动状态
    game_map_offset: usize, // GAMEMAPOFFSET（以 tile 为单位）
    scroll_x: usize,        // 像素级 X 滚动 (0-15)
    scroll_y: usize,        // 像素级 Y 滚动 (0-7)
    scroll_timer: usize,
}

impl TileMap {
    const VRAM_WIDTH: usize = 32;
    const VRAM_HEIGHT: usize = 32;
    const VIEW_WIDTH: usize = 15;   // 可视区域宽度（tile）
    const VIEW_HEIGHT: usize = 20;  // 可视区域高度（tile）
    const INITIAL_OFFSET: usize = 0x258 / 2; // 300 tiles
    
    fn new() -> Self {
        let raw = source("../graphics/bgTiles.inc");
        let map_source = source("../graphics/tilemap.inc");
        
        // 解析 tilemap：每 2 字节一个 tile 索引
        let mut map = Vec::new();
        for i in 0..map_source.len() / 2 {
            let lo = map_source[i * 2] as u16;
            let hi = map_source[i * 2 + 1] as u16;
            map.push(lo | (hi << 8));
        }
        
        // 初始化 VRAM (32x32)，全部清零
        let vram = vec![0u16; Self::VRAM_WIDTH * Self::VRAM_HEIGHT];
        
        let mut tilemap = Self {
            raw,
            map,
            vram,
            tile_size: 8,
            game_map_offset: Self::INITIAL_OFFSET,
            scroll_x: 0,
            scroll_y: 0,
            scroll_timer: 0,
        };
        
        tilemap.graphics_init();
        tilemap
    }
    
    /// 模拟 GRAPHICSINIT 宏
    fn graphics_init(&mut self) {
        // 从 tilemap 开头读取 15x20 tiles
        // 写入 TILEMAP0 的偏移 0x5E（47 tiles）位置
        // 47 = 1 * 32 + 15，即 (列15, 行1)
        
        let mut src_idx = 0;
        let vram_start_x = 15;  // 0x5E / 2 % 32 = 47 % 32 = 15
        let vram_start_y = 1;   // 0x5E / 2 / 32 = 47 / 32 = 1
        
        for row in 0..Self::VIEW_HEIGHT {
            for col in 0..Self::VIEW_WIDTH {
                if src_idx < self.map.len() {
                    let vram_x = vram_start_x + col;
                    let vram_y = vram_start_y + row;
                    
                    // VRAM 是环形的（wrap around）
                    let vram_idx = (vram_y % Self::VRAM_HEIGHT) * Self::VRAM_WIDTH 
                                 + (vram_x % Self::VRAM_WIDTH);
                    
                    self.vram[vram_idx] = self.map[src_idx];
                    src_idx += 1;
                }
            }
            // 每行结束后，ADD RBX, 022H 跳过 17 个 tile
            // 但源指针继续顺序读取，所以这里不需要额外操作
        }
    }
    
    /// 从 tile 索引和像素位置获取颜色
    fn get_tile_pixel(&self, tile_index: u16, px: usize, py: usize) -> Option<(u8, u8, u8)> {
        if tile_index == 0 {
            return Some((0, 0, 0)); // 空 tile 显示黑色
        }
        
        // 每个 tile 是 8x8 像素，每像素 4 字节 (BGRA)
        let tile_data_size = 8 * 8 * 4; // 256 bytes per tile
        let tile_offset = (tile_index as usize) * tile_data_size;
        let pixel_offset = tile_offset + (py * 8 + px) * 4;
        
        if pixel_offset + 3 < self.raw.len() {
            let b = self.raw[pixel_offset];
            let g = self.raw[pixel_offset + 1];
            let r = self.raw[pixel_offset + 2];
            let a = self.raw[pixel_offset + 3];
            
            // if a == 0 {
            //     return Some((0, 0, 0)); // 透明像素显示黑色背景
            // }
            
            Some((r, g, b))
        } else {
            Some((255, 0, 255)) // 越界显示品红色（调试用）
        }
    }
    
    /// 获取指定帧、指定像素位置的颜色
    /// x: 0..119 (15 tiles * 8 pixels)
    /// y: 0..159 (20 tiles * 8 pixels)
    fn get_color(&self, frame: usize, x: usize, y: usize) -> Option<(u8, u8, u8)> {
        // 计算当前帧的滚动偏移
        // 根据汇编：scroll_x 每帧+1，scroll_y 每2帧+1
        let scroll_x = (frame % 16) as isize;
        let scroll_y = ((frame / 2) % 8) as isize;
        
        // 应用滚动偏移（地图向左上滚动 = 视角向右下移动）
        // TM0XOFFSET = 256 - SCROLLX（反向）
        let adjusted_x = x as isize + (16 - scroll_x);
        let adjusted_y = y as isize - scroll_y;
        
        if adjusted_x < 0 || adjusted_y < 0 {
            return Some((0, 0, 0));
        }
        
        let adjusted_x = adjusted_x as usize;
        let adjusted_y = adjusted_y as usize;
        
        // 计算在 VRAM 中的 tile 坐标
        let tile_x = adjusted_x / self.tile_size;
        let tile_y = adjusted_y / self.tile_size;
        
        // tile 内的像素坐标
        let px = adjusted_x % self.tile_size;
        let py = adjusted_y % self.tile_size;
        
        // 映射到 VRAM 位置（考虑初始偏移）
        let vram_x = (tile_x + 15) % Self::VRAM_WIDTH;  // +15 因为数据从列15开始
        let vram_y = (tile_y + 1) % Self::VRAM_HEIGHT;  // +1 因为数据从行1开始
        
        let vram_idx = vram_y * Self::VRAM_WIDTH + vram_x;
        let tile_index = self.vram.get(vram_idx).copied().unwrap_or(0);
        
        self.get_tile_pixel(tile_index, px, py)
    }
    
    /// 简化版：只获取第一帧，不考虑滚动
    fn get_color_frame0(&self, x: usize, y: usize) -> Option<(u8, u8, u8)> {
        // 屏幕坐标 (x, y) 直接映射到 VRAM
        let tile_x = x / self.tile_size;
        let tile_y = y / self.tile_size;
        let px = x % self.tile_size;
        let py = y % self.tile_size;
        
        // VRAM 中的位置
        let vram_x = tile_x + 15;  // 初始 X 偏移
        let vram_y = tile_y + 1;   // 初始 Y 偏移
        
        if vram_x >= Self::VRAM_WIDTH || vram_y >= Self::VRAM_HEIGHT {
            return Some((0, 0, 0));
        }
        
        let vram_idx = vram_y * Self::VRAM_WIDTH + vram_x;
        let tile_index = self.vram.get(vram_idx).copied().unwrap_or(0);
        
        self.get_tile_pixel(tile_index, px, py)
    }
}

fn texture(index: usize, display: &Display<WindowSurface>) -> glium::texture::Texture2d {
    let tiles = source("../graphics/spriteTiles.inc");
    let tiles2 = source("../graphics/spriteTiles2.inc");
    let bg_tiles = TileMap::new();

    let mut rgb = Vec::<u8>::new();

    for y in 0 .. 32 * 8 * 2 {
        let is_extra_space = y < 32 * 8;
        let y = 32 * 8 - 1 - y % (32 * 8);
        for x in 0 .. 32 * 8 * 2 {
            if is_extra_space {
                if x >= 120 || y >= 160 {
                    rgb.extend(&[255, 255, 255]);
                    continue;
                }
                // println!("x {x}, y {y}");
                let color = bg_tiles.get_color(index, x, y).unwrap_or((255, 0, 255));
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


    let image = glium::texture::RawImage2d {
        data: std::borrow::Cow::Borrowed(&rgb),
        width: 32 * 8 * 2,
        height: 32 * 8 * 2,
        format: glium::texture::ClientFormat::U8U8U8,
    };
    glium::texture::Texture2d::new(display, image).unwrap()

}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    
    let event_loop = winit::event_loop::EventLoop::new().unwrap();
    event_loop.set_control_flow(ControlFlow::Poll);
    let (window, display) = SimpleWindowBuilder::new().build(&event_loop);

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

    let texture = texture(0, &display);

    let app = &mut App {
        window,
        display,
        vertex_buffer,
        indices,
        program,
        texture,
        last_draw: (Instant::now(), 0),
    };

    event_loop.run_app(app)?;
    Ok(())
}

struct App {
    window: Window,
    display: Display<WindowSurface>,
    vertex_buffer: glium::VertexBuffer<Vertex>,
    indices: glium::index::NoIndices,
    program: glium::Program,
    texture: glium::texture::Texture2d,
    last_draw: (Instant, usize),
}

impl ApplicationHandler for App {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        
        let (window, display) = SimpleWindowBuilder::new().build(event_loop);

        let vertices = [
            Vertex { pos: [-1.0, -1.0], tex: [0.0, 0.0] },
            Vertex { pos: [ 1.0, -1.0], tex: [1.0, 0.0] },
            Vertex { pos: [-1.0,  1.0], tex: [0.0, 1.0] },
            Vertex { pos: [ 1.0,  1.0], tex: [1.0, 1.0] },
        ];
        let vertex_buffer = glium::VertexBuffer::new(&display, &vertices).unwrap();
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
        ).unwrap();

        let texture = texture(self.last_draw.1, &display);
        self.window = window;
        self.display = display;
        self.vertex_buffer = vertex_buffer;
        self.program = program;
        self.texture = texture;
    }

    fn window_event(&mut self, event_loop: &ActiveEventLoop, _id: WindowId, event: WindowEvent) {
        match event {
            WindowEvent::CloseRequested => {
                println!("The close button was pressed; stopping");
                event_loop.exit();
            },
            WindowEvent::RedrawRequested => {
                println!("RedrawRequested");
                if self.last_draw.0.elapsed().as_micros() > 10 {
                    self.last_draw.0 = Instant::now();
                    self.last_draw.1 += 1;
                    println!("Frame {}", self.last_draw.1);
                    self.texture = texture(self.last_draw.1, &self.display);
                    // self.window.request_redraw();
                    // return;
                }
                let mut frame = self.display.draw();
                frame.clear_color(0.1, 0.1, 0.1, 1.0);
                frame.draw(&self.vertex_buffer, &self.indices, &self.program,
                        &uniform!{ tex: &self.texture },
                        &Default::default()).unwrap();
                frame.finish().unwrap();
                // self.window.request_redraw();
            }
            _ => (),
        }
    }
}

#[derive(Copy, Clone)]
struct Vertex {
    pos: [f32; 2],
    tex: [f32; 2],
}
glium::implement_vertex!(Vertex, pos, tex);