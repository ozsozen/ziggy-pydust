# UDP Communication Bus Example

A minimalist example demonstrating how to create a UDP socket communication bus in Zig that is accessible from Python using pydust.

## Files Created

1. **example/udp_bus.zig** - The main Zig implementation
   - `UdpBus` class with UDP socket operations
   - Methods: `__init__`, `__del__`, `bind`, `set_recv_timeout`, `send_to`, `recv`, `recv_from`
   
2. **example/udp_bus.pyi** - Python type stub file (auto-generated)
   - Provides type hints for IDE support

3. **example/udp_bus_demo.py** - Demonstration script
   - Shows how to use the UDP bus for sending and receiving messages

4. **test/test_udp_bus.py** - Comprehensive test suite
   - Tests for creation, binding, sending, receiving, and multi-message scenarios

## Features

- **Socket Creation**: Initialize UDP sockets with host and port
- **Binding**: Bind sockets to specific addresses
- **Configurable Timeout**: Set receive timeouts to prevent indefinite blocking
- **Send Data**: Send UDP packets to specified destinations
- **Receive Data**: Receive UDP packets with optional buffer size
- **Receive with Source**: Receive packets and get sender's address/port
- **Automatic Cleanup**: Socket cleanup handled by `__del__`

## Usage Example

```python
from example import udp_bus

# Create and bind a server socket
server = udp_bus.UdpBus("127.0.0.1", 5000)
server.bind()
server.set_recv_timeout(5)

# Create a client socket
client = udp_bus.UdpBus("127.0.0.1", 0)

# Send a message
client.send_to("Hello UDP!", "127.0.0.1", 5000)

# Receive the message
result = server.recv_from(buffer_size=1024)
print(f"Received: {result['data'].decode()} from {result['host']}:{result['port']}")
```

## Running the Demo

```bash
poetry run python example/udp_bus_demo.py
```

## Running Tests

```bash
poetry run pytest test/test_udp_bus.py -v
```

## Implementation Details

- Uses Zig's standard library `std.posix` for socket operations
- Leverages `std.net.Address` for IP address parsing
- Properly handles network byte order for IP addresses
- Uses pydust's memory allocator for buffer management
- Returns Python bytes for received data
- Returns structured data (dict) for `recv_from` with data, host, and port

## Design Principles

This example follows pydust best practices:
- Minimal code footprint (~120 lines of Zig)
- Clear Python interface
- Proper error handling
- Memory-safe implementation
- Comprehensive test coverage
