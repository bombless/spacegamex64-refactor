use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let content = fs::read_to_string("graphics/loadImgShip.inc")?;
    let mut result = Vec::new();
    let mut limit = 100_000000;

    for line in content.lines() {
        if limit == 0 {
            break;
        }

        // 提取 "db " 之后的内容
        let after_db = line.split("db ").nth(1).unwrap_or("");

        // 按逗号分割
        for item in after_db.split(',') {
            // println!("Processing item: {}", item);
            let trimmed = item.trim();

            // 确保字符串至少有 4 个字符（例如 '0x12'）
            if trimmed.len() >= 3 {
                // 取第2和第3个字符（索引1和1）
                let c1 = trimmed.chars().nth(1).unwrap();
                let c2 = trimmed.chars().nth(2).unwrap();

                // 转换为数字（假设是十六进制字符）
                if let (Some(val1), Some(val2)) = (c1.to_digit(16), c2.to_digit(16)) {
                    let byte_val = val1 * 16 + val2;
                    result.push(byte_val as u8);
                }
            }
        }

        limit -= 1;
    }

    // 输出结果（类似 var_dump）
    // println!("result {:?}", result.len());
    println!("P3");
    println!("230");
    println!("140");
    println!("255");
    // for i in (0..result.len()).step_by(4) {
    //     println!("{} {} {}", result[i + 2], result[i + 1], result[i]); // println!("{", item);
    // }
    for i in 0 .. 140 {
        for j in 0 .. 230 {
            let offset = i * 230 * 4 + j * 4 + 140*230*4*2;
            println!("{} {} {}", result[offset + 2], result[offset + 1], result[offset]);
        }
    }

    Ok(())
}
