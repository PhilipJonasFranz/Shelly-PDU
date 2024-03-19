function promLabel(label, value) {
    return [label, "=", '"', value, '"'].join("");
}

var info = Shelly.getDeviceInfo();

var defaultLabels = [
    ["name", info.name],
    ["id", info.id],
    ["mac", info.mac],
    ["app", info.app],
    ["switch", "0"],
].map(function (data) {
    return promLabel(data[0], data[1]);
}).join(",");

function printPrometheusMetric(name, value) {
    return ["shelly_", name, "{", defaultLabels, "}", " ", value, "\n"].join("");
}

function getData() {
    var sys = Shelly.getComponentStatus("sys");
    var sw = Shelly.getComponentStatus("switch:0");

    return [
        printPrometheusMetric("uptime_seconds", sys.uptime),
        printPrometheusMetric("ram_size_bytes", sys.ram_size),
        printPrometheusMetric("ram_free_bytes", sys.ram_free),
        printPrometheusMetric("switch_power_watts", sw.apower),
        printPrometheusMetric("switch_voltage_volts", sw.voltage),
        printPrometheusMetric("switch_current_amperes", sw.current),
        printPrometheusMetric("temperature_celsius", sw.temperature.tC),
        printPrometheusMetric("switch_power_watthours_total", sw.aenergy.total),
    ].join("");
}