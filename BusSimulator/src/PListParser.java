import java.io.IOException;
import java.util.List;

import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.SAXException;

public class PListParser {
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
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return handler.getCoords();
    }
}