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

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 1. 解析成 Vec<u8>
    let tiles = source("../graphics/spriteTiles.inc");
    let tiles2 = source("../graphics/spriteTiles2.inc");

    // 2. 取 rgb 数据
    let mut rgb = Vec::<u8>::new();

    for y in 0 .. 32 * 8 {
        let y = 32 * 8 - 1 - y;
        for x in 0 .. 32 * 8 * 2 {
            let tiles = if x < 32 * 8 { &tiles } else { &tiles2 };
            let i = x % (32 * 8) / 32;
            let j = y / 32;
            let n = i * 8 + j;
            let data = get_image(n, tiles);
            let offset = y % 32 * 32 * 3 + x % (32 * 8) % 32 * 3;
            rgb.extend(&[data[offset], data[offset + 1], data[offset + 2]]);
        }
    }


    // 3. 创建窗口
    let event_loop = glium::glutin::event_loop::EventLoop::new();
    let wb = glium::glutin::window::WindowBuilder::new()
                .with_title("inc 图片")
                .with_inner_size(glium::glutin::dpi::LogicalSize::new(512, 256));
    let cb = glium::glutin::ContextBuilder::new();
    let display = Display::new(wb, cb, &event_loop)?;

    // 4. 把 rgb 数据做成纹理
    let image = glium::texture::RawImage2d {
        data: std::borrow::Cow::Borrowed(&rgb),
        width: 32 * 8 * 2,
        height: 32 * 8,
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