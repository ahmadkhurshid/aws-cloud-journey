"""A tiny web app that reports which machine answered."""

import socket
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8080


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        message = f"Hello from {socket.gethostname()}\n"
        self.wfile.write(message.encode())

    def log_message(self, format, *args):
        print(f"{self.address_string()} - {format % args}", flush=True)


if __name__ == "__main__":
    print(f"Listening on port {PORT}", flush=True)
    HTTPServer(("", PORT), Handler).serve_forever()
