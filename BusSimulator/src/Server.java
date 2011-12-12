import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketException;
import java.net.UnknownHostException;
import java.util.HashSet;
import java.util.Set;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

/**
 * When the server is started, it listens for incoming TCP-connections and
 * registers hosts that request to be registered. Acts likewise for
 * unregistering. The server also has the possibility to send out UDP messages.
 * 
 * @author Matthias v. Treuberg
 * 
 */
public class Server extends Thread {
    // Server listens at port: 1234

    private Set<InetAddress> hosts;
    private Set<JSONObject> messages;
    private final static int HOSTS_PORT = 4321;
    private final static int SERVER_PORT = 1234;
    private final static String REGISTER_CMD = "HELLO SERVER";
    private final static String UNREGISTER_CMD = "UNREGISTER";

    public Server() {
        hosts = new HashSet<InetAddress>();
        messages = new HashSet<JSONObject>();
    }

    @Override
    public void run() {
        ServerSocket serverSocket = null;
        try {
            serverSocket = new ServerSocket(SERVER_PORT);
            System.out.println("Server started: "
                + InetAddress.getLocalHost().getHostAddress() + ":"
                + SERVER_PORT);
            while (true) {
                Socket sock = serverSocket.accept();
                BufferedReader reader = new BufferedReader(
                    new InputStreamReader(sock.getInputStream()));
                String host = sock.getInetAddress().getHostAddress();
                String msg = reader.readLine();

                if (msg.equals(REGISTER_CMD)) {
                    registerHost(host);
                } else if (msg.equals(UNREGISTER_CMD)) {
                    unregisterHost(host);
                } else {
                    System.out.println("Server received unknown command: "
                        + msg + " from host " + host);
                }
                sock.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Sends a UDP message to all registered hosts of the server.
     * 
     * @param message A message.
     */
    private void sendMessageToHosts(JSONObject message) {
        for (InetAddress addr : hosts) {
            DatagramPacket packet = new DatagramPacket(message.toJSONString()
                .getBytes(), message.toJSONString().length(), addr, HOSTS_PORT);
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
     * Sends all gathered messages to the hosts. Use 'addMessage' to add
     * messages in advance.
     */
    @SuppressWarnings("unchecked")
    public void sendMessages() {
        // create a JSON with all messages (also JSONs) in it
        JSONObject json = new JSONObject();
        JSONArray jarr = new JSONArray();
        jarr.addAll(messages);
        json.put("messages", jarr);

        // send a single JSON to each host. That JSON contains multiple JSONs
        sendMessageToHosts(json);
        // remove all messages
        messages.clear();
    }

    /**
     * Add a message that will be gathered and later on sent together.
     * 
     * @param message Message to be sent.
     */
    public void addMessage(JSONObject message) {
        messages.add(message);
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
            return;
        }
        hosts.add(addr);
        System.out.println("Server registered host: " + host);
        System.out.println("-- new nr of hosts: " + hosts.size());
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
            return;
        }
        hosts.remove(addr);
        System.out.println("Server unregistered host: " + host);
        System.out.println("-- new nr of hosts: " + hosts.size());
    }
}
