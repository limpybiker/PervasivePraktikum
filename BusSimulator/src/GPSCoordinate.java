public class GPSCoordinate {

    private Double latitude;
    private Double longitude;

    /**
     * @param latitude
     * @param longitude
     */
    public GPSCoordinate(Double latitude, Double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public GPSCoordinate() {
        this.latitude = 0d;
        this.longitude = 0d;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }
}
