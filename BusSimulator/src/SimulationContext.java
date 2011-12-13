
/**
 * @author Matthias v. Treuberg
 *
 */
public class SimulationContext {

	private int bus_id;
	private String route_number;
	private String route_destination;
	private String plist_filepath;
	
	public SimulationContext(String route_number, String route_destination, String plist_filepath){
		this.route_destination = route_destination;
		this.route_number = route_number;
		this.plist_filepath = plist_filepath;
		this.bus_id = this.hashCode();
	}

	public int getBus_id() {
		return bus_id;
	}

	public String getRoute_number() {
		return route_number;
	}

	public String getRoute_destination() {
		return route_destination;
	}

	public String getPlist_filepath() {
		return plist_filepath;
	}
}
