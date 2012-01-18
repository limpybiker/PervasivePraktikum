import java.util.LinkedList;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

/**
 * A custom Handler for the PLists we use in this project.
 * 
 * @author Matthias v. Treuberg
 * 
 */
public class CoordinateHandler extends DefaultHandler {

    private final static String TAG_REAL = "real";
    private final static String TAG_ARRAY = "array";
    private boolean lastWasReal = false;
    private boolean currentIsReal = false;
    private boolean currentIsArray = false;
    private List<GPSCoordinate> coords;
    private GPSCoordinate coord;

    public CoordinateHandler() {
        this.coords = new LinkedList<GPSCoordinate>();
        this.coord = new GPSCoordinate();
    }

    @Override
    public void characters(char[] ch, int start, int length)
        throws SAXException {
        Double value = 0d;
        boolean coordFinished = false;

        if (currentIsArray && lastWasReal && currentIsReal) {
            // this is longitude
            value = new Double(new String(ch, start, length));
            coord.setLongitude(value);
            coordFinished = true;
            lastWasReal = false;
            currentIsReal = false;

        } else if (currentIsArray && currentIsReal) {
            value = new Double(new String(ch, start, length));
            // this is latitude
            coord.setLatitude(value);
            lastWasReal = true;
            currentIsReal = false;
        }

        if (coordFinished) {
            coords.add(coord);
            coord = new GPSCoordinate();
        }

    }

    @Override
    public void endElement(String uri, String localName, String qName)
        throws SAXException {
        if (qName.equals(TAG_ARRAY)) {
            currentIsArray = false;
        }

    }

    @Override
    public void startElement(String uri, String localName, String qName,
        Attributes attributes) throws SAXException {
        if (qName.equals(TAG_REAL)) {
            currentIsReal = true;
        } else if (qName.equals(TAG_ARRAY)) {
            currentIsArray = true;
        }
    }

    public List<GPSCoordinate> getCoords() {
        return this.coords;
    }

}
