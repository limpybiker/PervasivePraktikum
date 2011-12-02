import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.HashSet;
import java.util.Set;

/**
 * @author Matthias v. Treuberg
 * 
 */
public class Server extends Thread {
    // Server listens at port: 1234

    private Set<InetAddress> hosts;
    private final static int HOSTS_PORT = 4321;

    public Server() {
        hosts = new HashSet<InetAddress>();
    }

    @Override
    public void run() {
        try {
            DatagramSocket dsock = new DatagramSocket(1234);
            byte[] buffer = new byte[2048];
            DatagramPacket packet = new DatagramPacket(buffer, buffer.length);

            // Now loop forever, waiting to receive packets and printing them.
            while (true) {
                // Wait to receive a datagram
                dsock.receive(packet);

                // Convert the contents to a string, and display them
                String msg = new String(buffer, 0, packet.getLength());
                String host = packet.getAddress().getHostName();
                if (msg.equals("HELLO SERVER")) {
                    registerHost(host);
                    System.out.println("Server registered host: "
                        + packet.getAddress().getHostName());
                } else if (msg.equals("UNREGISTER")) {
                    unregisterHost(host);
                    System.out.println("Server unregistered host: "
                        + packet.getAddress().getHostName());
                } else {
                    System.out.println("Server received: " + msg);
                }

                // Reset the length of the packet before reusing it.
                packet.setLength(buffer.length);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    /**
     * Sends a message to all registered hosts of the server.
     * 
     * @param message A message.
     */
    public void sendMessageToHosts(String message) {
        for (InetAddress addr : hosts) {
            DatagramPacket packet = new DatagramPacket(message.getBytes(),
                message.length(), addr, HOSTS_PORT);
            try {
                DatagramSocket dsock = new DatagramSocket();
                dsock.send(packet);
                dsock.close();
            } catch (SocketException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Add a host to the set of hosts.
     * 
     * @param host IP of a host.
     */
    public void registerHost(String host) {
        InetAddress addr = null;
        try {
            addr = InetAddress.getByName(host);
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        hosts.add(addr);
    }

    /**
     * Remove a host from the set of hosts.
     * 
     * @param host IP of a host.
     */
    public void unregisterHost(String host) {
        InetAddress addr = null;
        try {
            addr = InetAddress.getByName(host);
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
        hosts.remove(addr);
    }

    // /**
    // * Sends a message to a certain address to a certain port.
    // *
    // * @param host IP-Address to send the message to.
    // * @param port Port to send message to.
    // * @param message The message.
    // */
    // public void sendMessage(String host, String message) {
    // InetAddress addr = null;
    // try {
    // addr = InetAddress.getByName(host);
    // } catch (UnknownHostException e) {
    // e.printStackTrace();
    // }
    //
    // DatagramPacket packet = new DatagramPacket(message.getBytes(),
    // message.length(), addr, PORT);
    // try {
    // DatagramSocket dsock = new DatagramSocket();
    // dsock.send(packet);
    // dsock.close();
    // } catch (SocketException e) {
    // e.printStackTrace();
    // } catch (IOException e) {
    // e.printStackTrace();
    // }
    // }
}
