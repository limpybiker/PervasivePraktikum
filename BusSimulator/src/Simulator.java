import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

/**
 * @author Matthias v. Treuberg
 * 
 */
public class Simulator extends Thread {

    // ~7punkte auf 80m
    private final static Double DISTANCE_THRESHOLD = 0.0001;
    private final static long SLEEP_MILLIS = 500;
    private Server server;
    private final static String HOST = "127.0.0.1";
    private final static int PORT = 1234;
    private final static String FILEPATH = ".\\route_4_to_achleiten.plist";

    public Simulator() {
        server = new Server();
    }

    public static void main(String[] args) {
        Simulator s = new Simulator();
        s.run();
    }

    @Override
    public void run() {
        PListParser parser = new PListParser();
        List<GPSCoordinate> coords = parser.parsePList(FILEPATH);
        List<GPSCoordinate> movementPath = createMovementPath(coords);
        Iterator<GPSCoordinate> it = movementPath.iterator();

        while (it.hasNext()) {

            String message = createJSONfromGPSCoordinate(it.next());
            server.sendMessage(HOST, PORT, message);
            try {
                sleep(SLEEP_MILLIS);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Takes a list of coordinates and adds coordinates in between if the
     * distance between two coordinates is greater than THRESHOLD.
     * 
     * @param coords The list of coordinates.
     * @return A list like coords, just that points are added in between, with
     *         distance THRESHOLD.
     */
    private List<GPSCoordinate> createMovementPath(List<GPSCoordinate> coords) {
        Double lat1 = 0d;
        Double long1 = 0d;
        Double lat2 = 0d;
        Double long2 = 0d;
        List<GPSCoordinate> movementPath = new LinkedList<GPSCoordinate>();

        Iterator<GPSCoordinate> it = coords.iterator();
        if (it.hasNext()) {
            GPSCoordinate start = it.next();
            lat1 = start.getLatitude();
            long1 = start.getLongitude();
            movementPath.add(start);
        }
        while (it.hasNext()) {
            GPSCoordinate coord2 = it.next();
            movementPath.add(coord2);
            lat2 = coord2.getLatitude();
            long2 = coord2.getLongitude();
            Double distance = Math.sqrt(Math.pow((lat1 - lat2), 2)
                + Math.pow((long1 - long2), 2));

            int nrOfPoints = (int) Math.floor(distance / DISTANCE_THRESHOLD);
            double m = (long2 - long1) / (lat2 - lat1);

            for (int i = 1; i < nrOfPoints; i++) {
                GPSCoordinate p_new = new GPSCoordinate(lat1
                    + (DISTANCE_THRESHOLD * m * i), long1
                    + (DISTANCE_THRESHOLD * m * i) * m);
                movementPath.add(p_new);
            }
            // set last point new
            lat1 = lat2;
            long1 = long2;
        }

        return movementPath;
    }

    /**
     * Creates a JSON String from a GPSCoordinate.
     * 
     * @param coord GPSCoordinate.
     * @return Coordinate as JSON.
     */
    private String createJSONfromGPSCoordinate(GPSCoordinate coord) {
        String JSON = "{\"timestamp\":123456789,\"route_number\":\"4\",\"route_destination\":\"Achleiten\",\"latitude\":"
            + coord.getLatitude().toString()
            + ",\"longitude\":"
            + coord.getLongitude().toString() + "}";

        return JSON;
    }
}
