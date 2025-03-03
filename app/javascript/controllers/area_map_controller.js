import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
    static targets = ["map", "coordinates", "saveButton"]
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
        this.map.editTools.startPolygon();

        this.resetPolygon();

        this.map.on("editable:drawing:mouseup", (e) => {
            this.updatePolygonArea(e);
        });
    }

    updatePolygonArea(e) {
        const polygonPointsLength = e.layer.getLatLngs()[0].length;
        if (polygonPointsLength >= 2) {
            // Enable save button
            this.saveButtonTarget.disabled = false;
        }
    }

    savePolygon() {
        this.map.editTools.stopDrawing();
        this.polygonArea = [];
        
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                this.polygonArea = layer.getLatLngs()[0];
            }
        });

        this.coordinatesTarget.value = JSON.stringify(this.polygonArea.map((point) => [point.lat, point.lng]));
    }

    resetPolygon() {
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                this.map.removeLayer(layer);
            }
        });
        this.polygonArea = [];
        this.saveButtonTarget.disabled = true;
    }
}