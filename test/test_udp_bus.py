"""
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import socket
import threading
import time

from example import udp_bus


def test_udp_bus_create():
    """Test creating a UDP bus instance."""
    bus = udp_bus.UdpBus("127.0.0.1", 0)
    assert bus is not None


def test_udp_bus_bind():
    """Test binding a UDP socket."""
    bus = udp_bus.UdpBus("127.0.0.1", 0)
    bus.bind()


def test_udp_bus_send_recv():
    """Test sending and receiving data through UDP."""
    # Create sender and receiver
    receiver = udp_bus.UdpBus("127.0.0.1", 9998)
    receiver.bind()
    receiver.set_recv_timeout(5)
    
    sender = udp_bus.UdpBus("127.0.0.1", 0)
    
    # Send data first, then receive
    sender.send_to("Hello UDP!", "127.0.0.1", 9998)
    
    # Receive data (will wait up to timeout)
    data = receiver.recv(buffer_size=1024)
    
    assert data == b"Hello UDP!"


def test_udp_bus_recv_from():
    """Test receiving data with sender address."""
    # Create receiver
    receiver = udp_bus.UdpBus("127.0.0.1", 10000)
    receiver.bind()
    receiver.set_recv_timeout(5)
    
    # Send data using Python's socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(b"Test message", ("127.0.0.1", 10000))
    
    # Receive data with address
    result = receiver.recv_from(buffer_size=1024)
    
    sock.close()
    
    assert result["data"] == b"Test message"
    assert result["host"] == "127.0.0.1"
    assert result["port"] > 0


def test_udp_bus_send_multiple():
    """Test sending multiple messages."""
    receiver = udp_bus.UdpBus("127.0.0.1", 10001)
    receiver.bind()
    receiver.set_recv_timeout(5)
    
    sender = udp_bus.UdpBus("127.0.0.1", 0)
    
    messages = ["msg1", "msg2", "msg3"]
    
    # Send all messages
    for msg in messages:
        sender.send_to(msg, "127.0.0.1", 10001)
    
    # Receive all messages
    received = []
    for _ in range(len(messages)):
        data = receiver.recv(buffer_size=1024)
        received.append(data)
    
    assert received == [b"msg1", b"msg2", b"msg3"]
