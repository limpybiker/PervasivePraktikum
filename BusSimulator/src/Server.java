import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;
import java.net.UnknownHostException;

/**
 * @author Matthias v. Treuberg
 * 
 */
public class Server {

    /**
     * Sends a message to a certain address to a certain port.
     * 
     * @param host IP-Address to send the message to.
     * @param port Port to send message to.
     * @param message The message.
     */
    public void sendMessage(String host, int port, String message) {
        InetAddress addr = null;
        try {
            addr = InetAddress.getByName(host);
        } catch (UnknownHostException e) {
            e.printStackTrace();
        }

        DatagramPacket packet = new DatagramPacket(message.getBytes(),
            message.length(), addr, port);
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