import java.io.IOException;
import java.util.List;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.SAXException;

/**
 * @author Matthias v. Treuberg
 * 
 */
public class PListParser {

    /**
     * Parses a macintosh PList with GPS-Coordinates into a List of
     * GPSCoordinates.
     * 
     * @param filepathPList Filepath where PList is.
     * @return List of coordinates.
     */
    public List<GPSCoordinate> parsePList(String filepathPList) {
        SAXParserFactory factory = SAXParserFactory.newInstance();
        CoordinateHandler handler = new CoordinateHandler();
        SAXParser saxParser = null;
        try {
            saxParser = factory.newSAXParser();
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            saxParser.parse(filepathPList, handler);
        } catch (SAXException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return handler.getCoords();
    }
}