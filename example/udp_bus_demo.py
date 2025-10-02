#!/usr/bin/env python3
"""
Simple example demonstrating the UDP communication bus.

This example shows how to use the UdpBus class to send and receive
UDP messages between two endpoints.
"""

from example import udp_bus


def simple_example():
    """Simple send and receive example."""
    print("Creating UDP server on 127.0.0.1:5000")
    
    # Create and bind server socket
    server = udp_bus.UdpBus("127.0.0.1", 5000)
    server.bind()
    server.set_recv_timeout(5)  # 5 second timeout
    
    # Create client socket (port 0 = let OS choose)
    client = udp_bus.UdpBus("127.0.0.1", 0)
    
    print("\nSending messages...")
    # Send messages to server
    messages = ["Hello", "UDP", "World"]
    for msg in messages:
        print(f"  Sending: {msg}")
        client.send_to(msg, "127.0.0.1", 5000)
    
    print("\nReceiving messages...")
    # Receive messages
    for i in range(3):
        result = server.recv_from(buffer_size=1024)
        print(f"  Received: {result['data'].decode()} from {result['host']}:{result['port']}")
    
    print("\nExample completed!")


if __name__ == "__main__":
    simple_example()
