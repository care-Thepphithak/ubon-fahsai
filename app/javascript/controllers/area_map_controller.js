import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
    static targets = ["map"]
    polygonArea = []

    connect() {
        const map = L.map(this.mapTarget, {
            center: [15.2313, 104.8567],
            zoom: 13,
            editable: true
        });
        const loadingControl = L.control({ position: 'topright' });
        this.map = map;

        L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: '&copy; OpenStreetMap'
        }).addTo(map);
    }

    startEditPolygon() {
        console.log("startEditPolygon");
        this.map.editTools.startPolygon();
    }

    updatePolygonArea(e) {
        const polygonPointsLength = e.layer.getLatLngs()[0].length;
        if (polygonPointsLength >= 2) {
            console.log("polygonPointsLength", polygonPointsLength);
            this.polygonArea = e.layer.getLatLngs()[0];
            console.log("polygonArea", this.polygonArea);
        }
    }

    endEditPolygon() {
        console.log("onSavePolygon");
        this.map.editTools.stopDrawing();
        this.polygonArea = [];
        
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                this.polygonArea = layer.getLatLngs()[0];
            }
        });

        console.log("polygonArea", this.polygonArea);
    }

    resetPolygon() {
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                this.map.removeLayer(layer);
            }
        });
        this.polygonArea = [];
    }
}