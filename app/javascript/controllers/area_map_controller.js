import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["map", "coordinates", "saveButton", "plsDrawArea"]
    static values = { currentCoordinates: Array }
    polygonArea = []

    connect() {
        const map = L.map(this.mapTarget, {
            center: [15.2313, 104.8567],
            zoom: 13,
            editable: true
        });
        
        this.map = map;

        L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
            attribution: '&copy; OpenStreetMap'
        }).addTo(map);

        if (this.currentCoordinatesValue.length > 0) {
            this.showCurrentArea();
            this.saveButtonTarget.disabled = false;
        }
    }

    showCurrentArea() {
        const polygon = L.polygon(this.currentCoordinatesValue).addTo(this.map);
        this.map.fitBounds(polygon.getBounds());
    }

    showArea(event) {
        this.clearLayer();

        const coordinates = event.currentTarget.dataset.coordinates;
        const polygon = L.polygon(JSON.parse(coordinates)).addTo(this.map);

        this.map.fitBounds(polygon.getBounds());
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
            this.saveButtonTarget.disabled = false;
            this.plsDrawAreaTarget.classList.add("hidden");
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
        this.clearLayer();
        this.polygonArea = [];
        this.saveButtonTarget.disabled = true;
        this.plsDrawAreaTarget.classList.remove("hidden");
    }

    clearLayer() {
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                this.map.removeLayer(layer);
            }
        });
    }
}