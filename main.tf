resource "local_file" "test" {
  filename = "hello.txt"
  content  = "Hello World!"
}