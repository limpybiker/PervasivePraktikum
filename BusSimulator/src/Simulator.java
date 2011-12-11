import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.json.simple.JSONObject;

/**
 * @author Matthias v. Treuberg
 * 
 */
public class Simulator extends Thread {

	// ~7punkte auf 80m
	private final static Double DISTANCE_THRESHOLD = 0.00005;
	// time how often the server sends out gps coords
	private final static long SLEEP_MILLIS = 500;
	private Server server;
	private Set<SimulationContext> simulations;

	public Simulator() {
		server = new Server();
		simulations = new HashSet<SimulationContext>();

		// ----------------
		// add simulations here:
		simulations.add(new SimulationContext("4", "Achleiten",
				"route_4_to_achleiten.plist"));
		simulations.add(new SimulationContext("4", "Hochstein",
				"route_4_to_hochstein.plist"));
//		simulations.add(new SimulationContext("8", "Koenigschalding", "route_8_to_koenigschalding.plist"));
//		simulations.add(new SimulationContext("8", "PEB", "route_8_to_peb.plist"));
	}

	public static void main(String[] args) {
		Simulator s = new Simulator();
		s.start();
	}

	private Map<SimulationContext, List<GPSCoordinate>> createSimulationsWithGPS() {
		PListParser parser = new PListParser();
		Map<SimulationContext, List<GPSCoordinate>> map = new HashMap<SimulationContext, List<GPSCoordinate>>();

		for (SimulationContext s : simulations) {
			List<GPSCoordinate> coords = parser.parsePList(s
					.getPlist_filepath());
			List<GPSCoordinate> movementPath = createMovementPath(coords);
			map.put(s, movementPath);
		}

		return map;
	}

	@Override
	public void run() {
		server.start();
		Map<SimulationContext, List<GPSCoordinate>> map = createSimulationsWithGPS();

		while (!map.isEmpty()) {
			for (SimulationContext s : map.keySet()) {
				List<GPSCoordinate> coords = map.get(s);

				if (!coords.isEmpty()) {
					GPSCoordinate gps = coords.remove(0);
					server.sendMessageToHosts(createJSONfromGPSCoordinate(gps,
							s));
				} else {
					map.remove(s);
				}

			}

			try {
				sleep(SLEEP_MILLIS);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		System.out.println("Finished all simulated entities!");
	}

	/**
	 * Takes a list of coordinates and adds coordinates in between if the
	 * distance between two coordinates is greater than THRESHOLD.
	 * 
	 * @param coords
	 *            The list of coordinates.
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

			lat2 = coord2.getLatitude();
			long2 = coord2.getLongitude();
			Double distance = Math.sqrt(Math.pow((lat1 - lat2), 2)
					+ Math.pow((long1 - long2), 2));

			int nrOfPoints = (int) Math.floor((distance) / DISTANCE_THRESHOLD);
			Double m = (long2 - long1) / (lat2 - lat1);
			Double t2 = (lat2 - lat1) / nrOfPoints;

			for (int i = 1; i < nrOfPoints; i++) {
				Double new_lat = t2 * i + lat1;
				Double new_long = long1 + (new_lat - lat1) * m;
				GPSCoordinate p_new = new GPSCoordinate(new_lat, new_long);
				movementPath.add(p_new);
			}

			// add the last point
			movementPath.add(coord2);
			// set last point new
			lat1 = lat2;
			long1 = long2;
		}

		return movementPath;
	}

	/**
	 * Creates a JSON String from a GPSCoordinate.
	 * 
	 * @param coord
	 *            GPSCoordinate.
	 * @param setting
	 *            A context setting.
	 * @return Coordinate as JSON.
	 */
	@SuppressWarnings("unchecked")
	private JSONObject createJSONfromGPSCoordinate(GPSCoordinate coord,
			SimulationContext setting) {
		JSONObject json = new JSONObject();
		json.put("timestamp", System.currentTimeMillis());
		json.put("route_number", setting.getRoute_number());
		json.put("route_destination", setting.getRoute_destination());
		json.put("latitude", coord.getLatitude());
		json.put("longitude", coord.getLongitude());
		json.put("bus_id", setting.getBus_id());

		return json;
	}
}
