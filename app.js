const API_BASE = window.location.origin;

// State Variables
let currentSku = null;
let charts = {
    national: null,
    scenario: null,
    history: null,
    state: null,
    weather: null,
    price: null
};

// Global Configuration for Chart.js Defaults in Dark Mode
Chart.defaults.color = "#94a3b8";
Chart.defaults.font.family = "'Inter', sans-serif";
Chart.defaults.plugins.tooltip.backgroundColor = "rgba(15, 23, 42, 0.9)";
Chart.defaults.plugins.tooltip.titleColor = "#f8fafc";
Chart.defaults.plugins.tooltip.bodyColor = "#e2e8f0";
Chart.defaults.plugins.tooltip.borderColor = "rgba(255, 255, 255, 0.1)";
Chart.defaults.plugins.tooltip.borderWidth = 1;
Chart.defaults.plugins.tooltip.padding = 12;

document.addEventListener("DOMContentLoaded", () => {
    initTabs();
    initSearch();
    initSliders();
    
    // Initial fetch
    fetchMetrics();
    fetchNationalChart();
    fetchStateChart();
    fetchEvaluationCharts();

    document.getElementById('refresh-national-btn').addEventListener('click', fetchNationalChart);
    document.getElementById('apply-scenario-btn').addEventListener('click', loadScenario);
});

// -----------------------------------------
// Tab Handling
// -----------------------------------------
function initTabs() {
    const tabs = document.querySelectorAll('.nav-btn');
    const contents = document.querySelectorAll('.tab-content');

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            // Remove active classes
            tabs.forEach(t => t.classList.remove('active'));
            contents.forEach(c => {
                c.classList.remove('active');
                c.classList.add('style-hidden');
            });

            // Add active to clicked tab
            tab.classList.add('active');
            const targetId = `tab-${tab.dataset.tab}`;
            const targetContent = document.getElementById(targetId);
            
            targetContent.classList.remove('style-hidden');
            // small delay to allow display flex to apply before opacity transition
            setTimeout(() => {
                targetContent.classList.add('active');
            }, 10);
            
            // Re-render chart sizes after tab switch
            Object.values(charts).forEach(c => c && c.resize());
        });
    });
}

// -----------------------------------------
// Sliders UI Link
// -----------------------------------------
function initSliders() {
    const ids = ['port-weeks', 'port-sec', 'price-pct', 'promo-lift'];
    ids.forEach(id => {
        const input = document.getElementById(id);
        const valSpan = document.getElementById(`val-${id}`);
        input.addEventListener('input', (e) => {
            valSpan.textContent = e.target.value;
        });
    });
}


// -----------------------------------------
// Global Search Logic
// -----------------------------------------
function initSearch() {
    const input = document.getElementById('global-search');
    const resultsDiv = document.getElementById('search-results');
    let debounceTimer;

    input.addEventListener('input', (e) => {
        clearTimeout(debounceTimer);
        const q = e.target.value.trim();
        if (q.length < 2) {
            resultsDiv.classList.add('hidden');
            return;
        }

        debounceTimer = setTimeout(async () => {
            try {
                const res = await fetch(`${API_BASE}/api/forecast/search?q=${encodeURIComponent(q)}`);
                const data = await res.json();
                
                if (data.error || !data.ids || data.ids.length === 0) {
                    resultsDiv.innerHTML = `<div class="search-result-item" style="color:var(--text-secondary)">No matches found</div>`;
                } else {
                    resultsDiv.innerHTML = data.ids.slice(0, 10).map(id => 
                        `<div class="search-result-item" data-id="${id}">${id}</div>`
                    ).join('');
                }
                resultsDiv.classList.remove('hidden');
            } catch (err) {
                console.error("Search error", err);
            }
        }, 400);
    });

    resultsDiv.addEventListener('click', (e) => {
        if (e.target.classList.contains('search-result-item') && e.target.dataset.id) {
            currentSku = e.target.dataset.id;
            document.getElementById('selected-sku-display').innerText = currentSku;
            input.value = currentSku;
            resultsDiv.classList.add('hidden');
            
            // Switch to Planner Tab
            document.querySelector('[data-tab="planner"]').click();
            loadScenario();
        }
    });

    // Close when clicked outside
    document.addEventListener('click', (e) => {
        if (!e.target.closest('.search-container') && !e.target.closest('.search-results')) {
            resultsDiv.classList.add('hidden');
        }
    });
}

// -----------------------------------------
// API & Chart Loading
// -----------------------------------------

async function fetchMetrics() {
    try {
        const res = await fetch(`${API_BASE}/api/metrics`);
        const data = await res.json();
        if (data.error) return;

        const container = document.getElementById('metrics-container');
        container.innerHTML = `
            <div class="metric-card glass-panel fade-in-up">
                <span class="metric-title">WMAPE (Ensemble)</span>
                <span class="metric-value">${parseFloat(data.wmape_ensemble || 0).toFixed(4)}</span>
            </div>
            <div class="metric-card glass-panel fade-in-up" style="animation-delay: 0.1s">
                <span class="metric-title">Interval Coverage</span>
                <span class="metric-value">${(parseFloat(data.calibration_p10_p90_coverage || 0) * 100).toFixed(1)}%</span>
            </div>
            <div class="metric-card glass-panel fade-in-up" style="animation-delay: 0.2s">
                <span class="metric-title">Coherence Gap</span>
                <span class="metric-value">${parseFloat(data.hierarchical_coherence_mape_gap || 0).toFixed(6)}</span>
            </div>
            <div class="metric-card glass-panel fade-in-up" style="animation-delay: 0.3s">
                <span class="metric-title">LGBM Weight</span>
                <span class="metric-value">${parseFloat(data.ensemble_weight_lgb || 0).toFixed(3)}</span>
            </div>
        `;
    } catch (e) {
        console.error(e);
    }
}

async function fetchNationalChart() {
    try {
        const res = await fetch(`${API_BASE}/api/forecast/national`);
        const data = await res.json();
        if (!data || data.length === 0) return;

        const labels = data.map(d => d.week_start.split('T')[0]);
        const values = data.map(d => d.fc_point);

        const ctx = document.getElementById('nationalChart').getContext('2d');
        if (charts.national) charts.national.destroy();

        charts.national = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'National Demand',
                    data: values,
                    borderColor: '#a78bfa',
                    backgroundColor: 'rgba(167, 139, 250, 0.2)',
                    borderWidth: 2,
                    pointBackgroundColor: '#a78bfa',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: getChartOptions()
        });
    } catch(e) {
        console.error(e);
    }
}

async function fetchStateChart() {
    try {
        const res = await fetch(`${API_BASE}/api/forecast/state`);
        const data = await res.json();
        if (!data || data.length === 0) return;

        // Group by state
        const datasets = [];
        const stateMap = {};
        
        data.forEach(row => {
            const date = row.week_start.split('T')[0];
            if (!stateMap[row.state_id]) stateMap[row.state_id] = { dates: [], values: [] };
            stateMap[row.state_id].dates.push(date);
            stateMap[row.state_id].values.push(row.fc_point);
        });

        // Pick distinct colors for top 3-4 states
        const colors = ['#3b82f6', '#ec4899', '#10b981', '#f59e0b', '#8b5cf6'];
        let colorIdx = 0;
        let commonLabels = [];

        Object.keys(stateMap).forEach(state => {
            if (commonLabels.length === 0) commonLabels = stateMap[state].dates;
            datasets.push({
                label: state,
                data: stateMap[state].values,
                borderColor: colors[colorIdx % colors.length],
                borderWidth: 2,
                tension: 0.3
            });
            colorIdx++;
        });

        const ctx = document.getElementById('stateChart').getContext('2d');
        if (charts.state) charts.state.destroy();

        charts.state = new Chart(ctx, {
            type: 'line',
            data: {
                labels: commonLabels,
                datasets: datasets
            },
            options: getChartOptions()
        });
    } catch(e) {
        console.error(e);
    }
}

async function fetchEvaluationCharts() {
    try {
        const res = await fetch(`${API_BASE}/api/forecast/weather-price`);
        const data = await res.json();
        if (data.error) return;

        // Weather Chart
        const weatherCtx = document.getElementById('weatherChart').getContext('2d');
        if (charts.weather) charts.weather.destroy();
        charts.weather = new Chart(weatherCtx, {
            type: 'line',
            data: {
                labels: data.weather.map(d => d.temp_bin + '°C'),
                datasets: [
                    {
                        label: 'Mean Sales',
                        data: data.weather.map(d => d.sales),
                        borderColor: '#f59e0b',
                        backgroundColor: 'rgba(245, 158, 11, 0.2)',
                        borderWidth: 2,
                        fill: true,
                        tension: 0.3,
                        yAxisID: 'y'
                    },
                    {
                        label: 'Avg Price ($)',
                        data: data.weather.map(d => d.sell_price),
                        borderColor: '#06b6d4',
                        backgroundColor: 'transparent',
                        borderDash: [5, 5],
                        borderWidth: 2,
                        tension: 0.3,
                        yAxisID: 'y1'
                    }
                ]
            },
            options: {
                ...getChartOptions(),
                scales: {
                    x: {
                        grid: { color: 'rgba(255, 255, 255, 0.05)' }
                    },
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        grid: { color: 'rgba(255, 255, 255, 0.05)' },
                        title: { display: true, text: 'Mean Sales', color: '#f8fafc' }
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        grid: { drawOnChartArea: false },
                        title: { display: true, text: 'Avg Price ($)', color: '#f8fafc' }
                    }
                }
            }
        });

        // Price Chart
        const priceCtx = document.getElementById('priceChart').getContext('2d');
        if (charts.price) charts.price.destroy();
        charts.price = new Chart(priceCtx, {
            type: 'bar',
            data: {
                labels: data.price.map(d => '$' + d.price_bin),
                datasets: [{
                    label: 'Mean Sales by Price Tier',
                    data: data.price.map(d => d.sales),
                    backgroundColor: '#10b981',
                    borderRadius: 4
                }]
            },
            options: getChartOptions()
        });
    } catch(e) {
        console.error(e);
    }
}

async function loadScenario() {
    if (!currentSku) {
        alert("Please search and select a SKU first!");
        return;
    }

    const payload = {
        sku_id: currentSku,
        port_weeks: parseInt(document.getElementById('port-weeks').value),
        port_severity: parseFloat(document.getElementById('port-sec').value),
        price_change_pct: parseFloat(document.getElementById('price-pct').value),
        promo_lift: parseFloat(document.getElementById('promo-lift').value)
    };

    try {
        const btn = document.getElementById('apply-scenario-btn');
        const origText = btn.innerText;
        btn.innerText = "Simulating...";
        
        const res = await fetch(`${API_BASE}/api/scenario`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });
        const data = await res.json();
        
        btn.innerText = origText;
        
        if (data.error) {
            console.error(data.error);
            return;
        }

        renderScenarioChart(data.forecast);
        if (data.history && data.history.length > 0) {
            renderHistoryChart(data.history);
        }
    } catch (e) {
        console.error(e);
        document.getElementById('apply-scenario-btn').innerText = "Apply & Simulate";
    }
}

function renderScenarioChart(fcData) {
    const labels = fcData.map(d => d.week_start.split('T')[0]);
    
    // We create a fan chart via 3 lines: p10, p50, p90. 
    // Chart.js natively doesn't have an area between two lines object but we can use fill: 0 to fill to the dataset 0
    const ctx = document.getElementById('scenarioChart').getContext('2d');
    if (charts.scenario) charts.scenario.destroy();

    charts.scenario = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: 'p10',
                    data: fcData.map(d => d.y_hat_p10),
                    borderColor: 'rgba(76, 201, 240, 0)',
                    borderWidth: 0,
                    pointRadius: 0,
                    fill: false
                },
                {
                    label: 'p90 Bound',
                    data: fcData.map(d => d.y_hat_p90),
                    backgroundColor: 'rgba(6, 182, 212, 0.15)', // Cyan tint fill
                    borderColor: 'rgba(6, 182, 212, 0.2)',
                    borderWidth: 1,
                    pointRadius: 0,
                    fill: '-1' // fill to previous dataset
                },
                {
                    label: 'p50 (Median)',
                    data: fcData.map(d => d.y_hat_p50),
                    borderColor: '#06b6d4',
                    backgroundColor: '#06b6d4',
                    borderWidth: 2,
                    tension: 0.3,
                    pointRadius: 3
                },
                {
                    label: 'Ensemble',
                    data: fcData.map(d => d.y_hat_ensemble),
                    borderColor: '#f59e0b',
                    borderDash: [5, 5],
                    borderWidth: 2,
                    tension: 0.3,
                    pointRadius: 0
                }
            ]
        },
        options: getChartOptions()
    });
}

function renderHistoryChart(histData) {
    const labels = histData.map(d => d.week_start.split('T')[0]);

    const ctx = document.getElementById('historyChart').getContext('2d');
    if (charts.history) charts.history.destroy();

    const datasets = [
        {
            type: 'bar',
            label: 'Actual',
            data: histData.map(d => d.y_actual),
            backgroundColor: '#3b82f6',
            borderRadius: 4
        },
        {
            type: 'line',
            label: 'Ensemble',
            data: histData.map(d => d.y_hat_ensemble),
            borderColor: '#f59e0b',
            borderWidth: 2,
            tension: 0.3
        }
    ];

    if (histData[0].y_hat_classical) {
        datasets.push({
            type: 'line',
            label: 'Classical',
            data: histData.map(d => d.y_hat_classical),
            borderColor: '#10b981',
            borderDash: [3, 3],
            borderWidth: 1.5,
            tension: 0.3
        });
    }

    charts.history = new Chart(ctx, {
        data: { labels: labels, datasets: datasets },
        options: getChartOptions()
    });
}


// Shared options for Chart.js
function getChartOptions() {
    return {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'top',
                labels: { usePointStyle: true, boxWidth: 6 }
            }
        },
        scales: {
            x: {
                grid: { color: 'rgba(255, 255, 255, 0.05)' },
                ticks: { maxTicksLimit: 12 }
            },
            y: {
                grid: { color: 'rgba(255, 255, 255, 0.05)' }
            }
        },
        interaction: {
            mode: 'index',
            intersect: false,
        }
    };
}
