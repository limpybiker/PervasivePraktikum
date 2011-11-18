import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;

public class Client {

    /**
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws IOException {
        // TODO Auto-generated method stub
        int port = 1234;
        DatagramSocket dsock = new DatagramSocket(port);
        byte[] buffer = new byte[2048];
        DatagramPacket packet = new DatagramPacket(buffer, buffer.length);

        // Now loop forever, waiting to receive packets and printing them.
        while (true) {
            // Wait to receive a datagram
            dsock.receive(packet);

            // Convert the contents to a string, and display them
            String msg = new String(buffer, 0, packet.getLength());
            System.out.println(packet.getAddress().getHostName() + ": " + msg);

            // Reset the length of the packet before reusing it.
            packet.setLength(buffer.length);
        }
    }

}
