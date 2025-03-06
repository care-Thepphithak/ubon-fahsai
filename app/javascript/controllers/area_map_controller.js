import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["map", "coordinates", "saveButton", "plsDrawArea", "setAreaButton", "finishEditButton"]
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

        if (this.coordinatesTarget.value) {
            this.plsDrawAreaTarget.classList.add("hidden");
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
        let existingPolygon = null;
        
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                existingPolygon = layer;
            }
        });
    
        if (existingPolygon) {
            existingPolygon.enableEdit();
            this.map.on("editable:editing", (e) => {
                this.updatePolygonArea(e);
            });
        } else {
            this.map.editTools.startPolygon();
            this.resetPolygon();
            this.map.on("editable:drawing:clicked", (e) => {
                this.updatePolygonArea(e);
            });
        }
        
        this.setAreaButtonTarget.classList.add("hidden");
        this.finishEditButtonTarget.classList.remove("hidden");
    }

    updatePolygonArea(e) {
        const polygonPointsLength = e.layer.getLatLngs()[0].length;
        if (polygonPointsLength >= 3) {
            this.saveButtonTarget.disabled = false;
            this.plsDrawAreaTarget.classList.add("hidden");
        }
    }

    savePolygon() {
        this.map.editTools.stopDrawing();
        this.polygonArea = [];
    
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                const points = layer.getLatLngs()[0];
                
                if (points.length < 3) {
                    this.resetPolygon();
                    return;
                }
    
                this.polygonArea = points;
                layer.disableEdit();
            }
        });
    
        if (this.polygonArea.length >= 3) {
            this.coordinatesTarget.value = JSON.stringify(
                this.polygonArea.map((point) => [point.lat, point.lng])
            );
        }
    }

    resetPolygon() {
        this.clearLayer();
        this.polygonArea = [];
        this.saveButtonTarget.disabled = true;
        this.plsDrawAreaTarget.classList.remove("hidden");
        this.setAreaButtonTarget.classList.remove("hidden");
        this.finishEditButtonTarget.classList.add("hidden");
    }

    finishEditArea() {
        this.finishEditButtonTarget.classList.add("hidden");
        this.setAreaButtonTarget.classList.remove("hidden");
        this.savePolygon();
    }

    clearLayer() {
        this.map.eachLayer((layer) => {
            if (layer instanceof L.Polygon) {
                this.map.removeLayer(layer);
            }
        });
    }
}