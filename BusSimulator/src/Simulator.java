import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

public class Simulator {

    // ~7punkte auf 80m
    private final static Double DISTANCE_THRESHOLD = 0.0001;

    /**
     * @param args
     */
    public static void main(String[] args) {
        String filepath = ".\\route_4_to_achleiten.plist";
        PListParser parser = new PListParser();

        List<GPSCoordinate> coords = parser.parsePList(filepath);
        // for (GPSCoordinate c : coords) {
        // System.out.println("Lat: " + c.getLatitude() + " Long: "
        // + c.getLongitude());
        // }

        // System.out
        // .println("Distance: "
        // + Math.floor((Math.sqrt(Math.pow(
        // (13.46226404474511 - 13.46246911430127), 2)
        // + Math.pow((48.59563746361783 - 48.59484076863929), 2)) /
        // DISTANCE_THRESHOLD)));
        Simulator s = new Simulator();
        // List<GPSCoordinate> two = new LinkedList<GPSCoordinate>();
        // two.add(new GPSCoordinate(48.57791773539429, 13.50295518233387));
        // two.add(new GPSCoordinate(48.57865615274315, 13.50303730127264));
        s.createMovementPath(coords);
    }

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
            // System.out.println("nrOfPoints: " + nrOfPoints);
            double m = (long2 - long1) / (lat2 - lat1);
            // System.out.println("m: " + m);

            for (int i = 1; i < nrOfPoints; i++) {
                GPSCoordinate p_new = new GPSCoordinate(lat1
                    + (DISTANCE_THRESHOLD * m * i), long1
                    + (DISTANCE_THRESHOLD * m * i) * m);
                movementPath.add(p_new);
                // System.out.println("P_new_lat: " + p_new.getLatitude());
                // System.out.println("P_new_long: " + p_new.getLongitude());
            }
            // set last point new
            lat1 = lat2;
            long1 = long2;
        }

        return movementPath;
    }
}
