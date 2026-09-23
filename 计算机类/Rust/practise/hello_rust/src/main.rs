fn greeting() -> String {
    String::from("Hello, world!")
}

fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn divide(a: i32, b: i32) -> i32 {
    a / b
}

fn main() {
    println!("{}", greeting());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_greeting() {
        assert_eq!(greeting(), "Hello, world!");
    }

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
        assert_eq!(add(-1, 1), 0);
    }

    #[test]
    #[should_panic(expected = "attempt to divide by zero")]
    fn test_divide_by_zero() {
        let _ = divide(1, 0);
    }
}
