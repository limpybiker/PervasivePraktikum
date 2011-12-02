import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;

public class Client {

    // Client listens at port: 4321
    private final static int HOST_PORT = 4321;
    private final static int SERVER_PORT = 1234;

    /**
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws IOException {
        // Send register message to server
        sendMessage("127.0.0.1", "HELLO SERVER");

        DatagramSocket dsock = new DatagramSocket(HOST_PORT);
        byte[] buffer = new byte[2048];
        DatagramPacket packet = new DatagramPacket(buffer, buffer.length);

        // Now loop forever, waiting to receive packets and printing them.
        int i = 0;
        while (i < 15) {
            // Wait to receive a datagram
            dsock.receive(packet);

            // Convert the contents to a string, and display them
            String msg = new String(buffer, 0, packet.getLength());
            System.out.println(packet.getAddress().getHostName() + ": " + msg);

            // Reset the length of the packet before reusing it.
            packet.setLength(buffer.length);
            i++;
        }
        sendMessage("127.0.0.1", "UNREGISTER");
    }

    /**
     * Sends a message to the server.
     * 
     * @param host
     * @param message
     */
    private static void sendMessage(String host, String message) {
        InetAddress addr = null;
        try {
            addr = InetAddress.getByName(host);
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }

        DatagramPacket packet = new DatagramPacket(message.getBytes(),
            message.length(), addr, SERVER_PORT);
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
