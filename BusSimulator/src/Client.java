import java.io.BufferedWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.Socket;
import java.net.UnknownHostException;

public class Client {

    // Client listens at port: 4321
    private final static int HOST_PORT = 4321;
    private final static int SERVER_PORT = 1234;
    private final static String SERVER_IP = "127.0.0.1";
    private final static String REGISTER_CMD = "HELLO SERVER";
    private final static String UNREGISTER_CMD = "UNREGISTER";

    /**
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws IOException {
        // Send register message to server
        sendMessage(SERVER_IP, REGISTER_CMD);

        // Open a UDP-socket to receive GPS-coords
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
        sendMessage(SERVER_IP, UNREGISTER_CMD);
        dsock.close();
    }

    /**
     * Sends a TCP-message to a host.
     * 
     * @param host Where to send the message.
     * @param message The message.
     */
    private static void sendMessage(String host, String message) {
        Socket socket = null;
        try {
            socket = new Socket(host, SERVER_PORT);
            BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(
                socket.getOutputStream()));
            writer.write(message);
            writer.flush();
            writer.close();
        } catch (UnknownHostException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
