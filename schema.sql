--
-- PostgreSQL database dump
--

\restrict mUwx2bH1hZ8u04bP1biZMefS0VoXYBMc26DCLHbortZw0DM4TYoadrBAnSCpeOY

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-04-11 09:59:45

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 234 (class 1259 OID 16921)
-- Name: disruption_scenario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.disruption_scenario (
    scenario_id integer NOT NULL,
    scenario_name character varying(100),
    affected_region character varying(50),
    store_id character varying(20),
    start_date date,
    duration_days integer,
    impact_factor numeric(4,2),
    scenario_type character varying(50)
);


ALTER TABLE public.disruption_scenario OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16920)
-- Name: disruption_scenario_scenario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.disruption_scenario_scenario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.disruption_scenario_scenario_id_seq OWNER TO postgres;

--
-- TOC entry 5108 (class 0 OID 0)
-- Dependencies: 233
-- Name: disruption_scenario_scenario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.disruption_scenario_scenario_id_seq OWNED BY public.disruption_scenario.scenario_id;


--
-- TOC entry 228 (class 1259 OID 16882)
-- Name: forecast_output; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.forecast_output (
    forecast_id integer NOT NULL,
    sku_id character varying(20),
    store_id character varying(20),
    forecast_date date,
    horizon_days integer,
    p10 numeric(10,2),
    p50 numeric(10,2),
    p90 numeric(10,2),
    model_used character varying(50),
    created_at timestamp without time zone
);


ALTER TABLE public.forecast_output OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16881)
-- Name: forecast_output_forecast_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.forecast_output_forecast_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.forecast_output_forecast_id_seq OWNER TO postgres;

--
-- TOC entry 5109 (class 0 OID 0)
-- Dependencies: 227
-- Name: forecast_output_forecast_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.forecast_output_forecast_id_seq OWNED BY public.forecast_output.forecast_id;


--
-- TOC entry 224 (class 1259 OID 16846)
-- Name: inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory (
    inventory_id integer NOT NULL,
    sku_id character varying(20),
    date date,
    stock_level integer,
    reorder_point integer,
    safety_stock integer,
    restock_qty integer,
    store_id character varying(20)
);


ALTER TABLE public.inventory OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16845)
-- Name: inventory_inventory_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_inventory_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_inventory_id_seq OWNER TO postgres;

--
-- TOC entry 5110 (class 0 OID 0)
-- Dependencies: 223
-- Name: inventory_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_inventory_id_seq OWNED BY public.inventory.inventory_id;


--
-- TOC entry 230 (class 1259 OID 16900)
-- Name: macro_indicators; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.macro_indicators (
    indicator_id integer NOT NULL,
    date date,
    store_id character varying(20),
    consumer_confidence_ind numeric(6,2),
    unemp_rate numeric(5,2),
    fuel_price numeric(8,2)
);


ALTER TABLE public.macro_indicators OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16899)
-- Name: macro_indicators_indicator_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.macro_indicators_indicator_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.macro_indicators_indicator_id_seq OWNER TO postgres;

--
-- TOC entry 5111 (class 0 OID 0)
-- Dependencies: 229
-- Name: macro_indicators_indicator_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.macro_indicators_indicator_id_seq OWNED BY public.macro_indicators.indicator_id;


--
-- TOC entry 219 (class 1259 OID 16815)
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    sku_id character varying(20) NOT NULL,
    sku_name character varying(100),
    category character varying(50),
    subcategory character varying(50),
    unit_price numeric(10,2),
    supplier_id character varying(20)
);


ALTER TABLE public.product OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16864)
-- Name: promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion (
    promo_id integer NOT NULL,
    sku_id character varying(20),
    store_id character varying(20),
    start_date date,
    end_date date,
    discount_pct numeric(5,2),
    promo_type character varying(50)
);


ALTER TABLE public.promotion OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16863)
-- Name: promotion_promo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.promotion_promo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.promotion_promo_id_seq OWNER TO postgres;

--
-- TOC entry 5112 (class 0 OID 0)
-- Dependencies: 225
-- Name: promotion_promo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.promotion_promo_id_seq OWNED BY public.promotion.promo_id;


--
-- TOC entry 222 (class 1259 OID 16828)
-- Name: sales_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_data (
    sales_id integer NOT NULL,
    sku_id character varying(20),
    store_id character varying(20),
    date date,
    quantity_sold bigint,
    revenue numeric(12,2),
    promo_flag boolean
);


ALTER TABLE public.sales_data OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16827)
-- Name: sales_data_sales_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_data_sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_data_sales_id_seq OWNER TO postgres;

--
-- TOC entry 5113 (class 0 OID 0)
-- Dependencies: 221
-- Name: sales_data_sales_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_data_sales_id_seq OWNED BY public.sales_data.sales_id;


--
-- TOC entry 236 (class 1259 OID 16934)
-- Name: social_trends; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.social_trends (
    trend_id integer NOT NULL,
    date date,
    sku_id character varying(20),
    category character varying(50),
    google_trend_index numeric(5,2),
    social_media_score numeric(5,2)
);


ALTER TABLE public.social_trends OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16933)
-- Name: social_trends_trend_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.social_trends_trend_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.social_trends_trend_id_seq OWNER TO postgres;

--
-- TOC entry 5114 (class 0 OID 0)
-- Dependencies: 235
-- Name: social_trends_trend_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.social_trends_trend_id_seq OWNED BY public.social_trends.trend_id;


--
-- TOC entry 220 (class 1259 OID 16821)
-- Name: store_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store_location (
    store_id character varying(20) NOT NULL,
    store_name character varying(100),
    city character varying(50),
    region character varying(50),
    country character varying(50)
);


ALTER TABLE public.store_location OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16913)
-- Name: weather_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_data (
    weather_id integer NOT NULL,
    date date,
    location_id character varying(20),
    temperature numeric(5,2)
);


ALTER TABLE public.weather_data OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16912)
-- Name: weather_data_weather_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.weather_data_weather_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weather_data_weather_id_seq OWNER TO postgres;

--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 231
-- Name: weather_data_weather_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weather_data_weather_id_seq OWNED BY public.weather_data.weather_id;


--
-- TOC entry 4905 (class 2604 OID 16924)
-- Name: disruption_scenario scenario_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disruption_scenario ALTER COLUMN scenario_id SET DEFAULT nextval('public.disruption_scenario_scenario_id_seq'::regclass);


--
-- TOC entry 4902 (class 2604 OID 16885)
-- Name: forecast_output forecast_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forecast_output ALTER COLUMN forecast_id SET DEFAULT nextval('public.forecast_output_forecast_id_seq'::regclass);


--
-- TOC entry 4900 (class 2604 OID 16849)
-- Name: inventory inventory_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory ALTER COLUMN inventory_id SET DEFAULT nextval('public.inventory_inventory_id_seq'::regclass);


--
-- TOC entry 4903 (class 2604 OID 16903)
-- Name: macro_indicators indicator_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.macro_indicators ALTER COLUMN indicator_id SET DEFAULT nextval('public.macro_indicators_indicator_id_seq'::regclass);


--
-- TOC entry 4901 (class 2604 OID 16867)
-- Name: promotion promo_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion ALTER COLUMN promo_id SET DEFAULT nextval('public.promotion_promo_id_seq'::regclass);


--
-- TOC entry 4899 (class 2604 OID 16831)
-- Name: sales_data sales_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_data ALTER COLUMN sales_id SET DEFAULT nextval('public.sales_data_sales_id_seq'::regclass);


--
-- TOC entry 4906 (class 2604 OID 16937)
-- Name: social_trends trend_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_trends ALTER COLUMN trend_id SET DEFAULT nextval('public.social_trends_trend_id_seq'::regclass);


--
-- TOC entry 4904 (class 2604 OID 16916)
-- Name: weather_data weather_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_data ALTER COLUMN weather_id SET DEFAULT nextval('public.weather_data_weather_id_seq'::regclass);


--
-- TOC entry 5100 (class 0 OID 16921)
-- Dependencies: 234
-- Data for Name: disruption_scenario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.disruption_scenario (scenario_id, scenario_name, affected_region, store_id, start_date, duration_days, impact_factor, scenario_type) FROM stdin;
1	Flood	Gujarat	ST001	2026-04-01	5	0.70	Natural
2	Strike	Maharashtra	ST002	2026-04-02	3	0.50	Human
3	Heatwave	Delhi	ST003	2026-04-03	7	0.60	Natural
4	Rain	Karnataka	ST004	2026-04-01	2	0.30	Natural
5	Cyclone	Tamil Nadu	ST005	2026-04-02	6	0.80	Natural
6	Transport Issue	Maharashtra	ST006	2026-04-03	4	0.40	Logistics
7	Flood	Gujarat	ST007	2026-04-04	5	0.70	Natural
8	Power Cut	Rajasthan	ST008	2026-04-01	2	0.20	Infrastructure
9	Strike	Telangana	ST009	2026-04-02	3	0.50	Human
10	Storm	West Bengal	ST010	2026-04-03	4	0.60	Natural
\.


--
-- TOC entry 5094 (class 0 OID 16882)
-- Dependencies: 228
-- Data for Name: forecast_output; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.forecast_output (forecast_id, sku_id, store_id, forecast_date, horizon_days, p10, p50, p90, model_used, created_at) FROM stdin;
1	SKU001	ST001	2026-04-01	7	3.00	5.00	8.00	ARIMA	2026-04-11 09:18:10.33214
2	SKU002	ST002	2026-04-01	7	2.00	4.00	6.00	ARIMA	2026-04-11 09:18:10.33214
3	SKU003	ST003	2026-04-01	7	8.00	12.00	18.00	LSTM	2026-04-11 09:18:10.33214
4	SKU004	ST004	2026-04-01	7	5.00	7.00	10.00	ARIMA	2026-04-11 09:18:10.33214
5	SKU005	ST005	2026-04-01	7	1.00	2.00	4.00	Prophet	2026-04-11 09:18:10.33214
6	SKU006	ST006	2026-04-01	7	3.00	6.00	9.00	LSTM	2026-04-11 09:18:10.33214
7	SKU007	ST007	2026-04-01	7	10.00	15.00	20.00	ARIMA	2026-04-11 09:18:10.33214
8	SKU008	ST008	2026-04-01	7	4.00	6.00	9.00	Prophet	2026-04-11 09:18:10.33214
9	SKU009	ST009	2026-04-01	7	1.00	2.00	3.00	ARIMA	2026-04-11 09:18:10.33214
10	SKU010	ST010	2026-04-01	7	2.00	3.00	5.00	LSTM	2026-04-11 09:18:10.33214
\.


--
-- TOC entry 5090 (class 0 OID 16846)
-- Dependencies: 224
-- Data for Name: inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory (inventory_id, sku_id, date, stock_level, reorder_point, safety_stock, restock_qty, store_id) FROM stdin;
1	SKU001	2026-04-01	50	20	10	30	ST001
2	SKU002	2026-04-01	40	15	8	25	ST002
3	SKU003	2026-04-01	100	50	20	60	ST003
4	SKU004	2026-04-01	80	30	15	40	ST004
5	SKU005	2026-04-01	30	10	5	20	ST005
6	SKU006	2026-04-01	60	25	10	35	ST006
7	SKU007	2026-04-01	120	60	25	70	ST007
8	SKU008	2026-04-01	70	30	15	40	ST008
9	SKU009	2026-04-01	20	8	4	15	ST009
10	SKU010	2026-04-01	25	10	5	18	ST010
\.


--
-- TOC entry 5096 (class 0 OID 16900)
-- Dependencies: 230
-- Data for Name: macro_indicators; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.macro_indicators (indicator_id, date, store_id, consumer_confidence_ind, unemp_rate, fuel_price) FROM stdin;
1	2026-04-01	ST001	98.50	5.20	102.00
2	2026-04-01	ST002	95.00	6.00	105.00
3	2026-04-01	ST003	97.20	5.50	103.00
4	2026-04-01	ST004	96.80	5.80	104.00
5	2026-04-01	ST005	94.50	6.20	106.00
6	2026-04-01	ST006	93.00	6.50	107.00
7	2026-04-01	ST007	99.10	4.80	101.00
8	2026-04-01	ST008	92.50	6.80	108.00
9	2026-04-01	ST009	91.20	7.00	109.00
10	2026-04-01	ST010	90.00	7.50	110.00
\.


--
-- TOC entry 5085 (class 0 OID 16815)
-- Dependencies: 219
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (sku_id, sku_name, category, subcategory, unit_price, supplier_id) FROM stdin;
SKU001	iPhone 14	Electronics	Mobile	80000.00	SUP1
SKU002	Samsung TV	Electronics	TV	60000.00	SUP2
SKU003	Nike Shoes	Fashion	Footwear	5000.00	SUP3
SKU004	Adidas T-Shirt	Fashion	Clothing	2000.00	SUP3
SKU005	Dell Laptop	Electronics	Laptop	70000.00	SUP4
SKU006	HP Printer	Electronics	Printer	12000.00	SUP5
SKU007	Boat Earbuds	Electronics	Audio	1500.00	SUP6
SKU008	Puma Jacket	Fashion	Clothing	4000.00	SUP3
SKU009	LG Fridge	Appliances	Refrigerator	45000.00	SUP7
SKU010	Sony Camera	Electronics	Camera	55000.00	SUP8
\.


--
-- TOC entry 5092 (class 0 OID 16864)
-- Dependencies: 226
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion (promo_id, sku_id, store_id, start_date, end_date, discount_pct, promo_type) FROM stdin;
1	SKU001	ST001	2026-04-01	2026-04-10	10.00	Festival
2	SKU002	ST002	2026-04-02	2026-04-12	15.00	Clearance
3	SKU003	ST003	2026-04-03	2026-04-13	20.00	Seasonal
4	SKU004	ST004	2026-04-01	2026-04-05	5.00	Flash
5	SKU005	ST005	2026-04-02	2026-04-08	12.00	Festival
6	SKU006	ST006	2026-04-03	2026-04-09	8.00	Clearance
7	SKU007	ST007	2026-04-04	2026-04-14	18.00	Seasonal
8	SKU008	ST008	2026-04-01	2026-04-06	7.00	Flash
9	SKU009	ST009	2026-04-02	2026-04-11	10.00	Festival
10	SKU010	ST010	2026-04-03	2026-04-12	14.00	Seasonal
\.


--
-- TOC entry 5088 (class 0 OID 16828)
-- Dependencies: 222
-- Data for Name: sales_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_data (sales_id, sku_id, store_id, date, quantity_sold, revenue, promo_flag) FROM stdin;
1	SKU001	ST001	2026-04-01	5	400000.00	t
2	SKU002	ST002	2026-04-01	3	180000.00	f
3	SKU003	ST003	2026-04-01	10	50000.00	t
4	SKU004	ST004	2026-04-01	8	16000.00	f
5	SKU005	ST005	2026-04-01	2	140000.00	t
6	SKU006	ST006	2026-04-01	4	48000.00	f
7	SKU007	ST007	2026-04-01	15	22500.00	t
8	SKU008	ST008	2026-04-01	6	24000.00	f
9	SKU009	ST009	2026-04-01	1	45000.00	t
10	SKU010	ST010	2026-04-01	2	110000.00	f
\.


--
-- TOC entry 5102 (class 0 OID 16934)
-- Dependencies: 236
-- Data for Name: social_trends; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.social_trends (trend_id, date, sku_id, category, google_trend_index, social_media_score) FROM stdin;
1	2026-04-01	SKU001	Electronics	75.00	80.00
2	2026-04-01	SKU002	Electronics	65.00	70.00
3	2026-04-01	SKU003	Fashion	85.00	90.00
4	2026-04-01	SKU004	Fashion	60.00	65.00
5	2026-04-01	SKU005	Electronics	78.00	82.00
6	2026-04-01	SKU006	Electronics	55.00	60.00
7	2026-04-01	SKU007	Electronics	88.00	92.00
8	2026-04-01	SKU008	Fashion	70.00	75.00
9	2026-04-01	SKU009	Appliances	50.00	55.00
10	2026-04-01	SKU010	Electronics	68.00	72.00
\.


--
-- TOC entry 5086 (class 0 OID 16821)
-- Dependencies: 220
-- Data for Name: store_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store_location (store_id, store_name, city, region, country) FROM stdin;
ST001	Ahmedabad Store	Ahmedabad	Gujarat	India
ST002	Mumbai Store	Mumbai	Maharashtra	India
ST003	Delhi Store	Delhi	Delhi	India
ST004	Bangalore Store	Bangalore	Karnataka	India
ST005	Chennai Store	Chennai	Tamil Nadu	India
ST006	Pune Store	Pune	Maharashtra	India
ST007	Surat Store	Surat	Gujarat	India
ST008	Jaipur Store	Jaipur	Rajasthan	India
ST009	Hyderabad Store	Hyderabad	Telangana	India
ST010	Kolkata Store	Kolkata	West Bengal	India
\.


--
-- TOC entry 5098 (class 0 OID 16913)
-- Dependencies: 232
-- Data for Name: weather_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.weather_data (weather_id, date, location_id, temperature) FROM stdin;
1	2026-04-01	Ahmedabad	35.00
2	2026-04-01	Mumbai	32.00
3	2026-04-01	Delhi	36.00
4	2026-04-01	Bangalore	28.00
5	2026-04-01	Chennai	34.00
6	2026-04-01	Pune	30.00
7	2026-04-01	Surat	33.00
8	2026-04-01	Jaipur	37.00
9	2026-04-01	Hyderabad	31.00
10	2026-04-01	Kolkata	29.00
\.


--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 233
-- Name: disruption_scenario_scenario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.disruption_scenario_scenario_id_seq', 10, true);


--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 227
-- Name: forecast_output_forecast_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.forecast_output_forecast_id_seq', 10, true);


--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 223
-- Name: inventory_inventory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_inventory_id_seq', 10, true);


--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 229
-- Name: macro_indicators_indicator_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.macro_indicators_indicator_id_seq', 10, true);


--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 225
-- Name: promotion_promo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.promotion_promo_id_seq', 10, true);


--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 221
-- Name: sales_data_sales_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_data_sales_id_seq', 10, true);


--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 235
-- Name: social_trends_trend_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.social_trends_trend_id_seq', 10, true);


--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 231
-- Name: weather_data_weather_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.weather_data_weather_id_seq', 10, true);


--
-- TOC entry 4924 (class 2606 OID 16927)
-- Name: disruption_scenario disruption_scenario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disruption_scenario
    ADD CONSTRAINT disruption_scenario_pkey PRIMARY KEY (scenario_id);


--
-- TOC entry 4918 (class 2606 OID 16888)
-- Name: forecast_output forecast_output_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forecast_output
    ADD CONSTRAINT forecast_output_pkey PRIMARY KEY (forecast_id);


--
-- TOC entry 4914 (class 2606 OID 16852)
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (inventory_id);


--
-- TOC entry 4920 (class 2606 OID 16906)
-- Name: macro_indicators macro_indicators_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.macro_indicators
    ADD CONSTRAINT macro_indicators_pkey PRIMARY KEY (indicator_id);


--
-- TOC entry 4908 (class 2606 OID 16820)
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (sku_id);


--
-- TOC entry 4916 (class 2606 OID 16870)
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (promo_id);


--
-- TOC entry 4912 (class 2606 OID 16834)
-- Name: sales_data sales_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_data
    ADD CONSTRAINT sales_data_pkey PRIMARY KEY (sales_id);


--
-- TOC entry 4926 (class 2606 OID 16940)
-- Name: social_trends social_trends_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_trends
    ADD CONSTRAINT social_trends_pkey PRIMARY KEY (trend_id);


--
-- TOC entry 4910 (class 2606 OID 16826)
-- Name: store_location store_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_location
    ADD CONSTRAINT store_location_pkey PRIMARY KEY (store_id);


--
-- TOC entry 4922 (class 2606 OID 16919)
-- Name: weather_data weather_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_data
    ADD CONSTRAINT weather_data_pkey PRIMARY KEY (weather_id);


--
-- TOC entry 4936 (class 2606 OID 16928)
-- Name: disruption_scenario disruption_scenario_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.disruption_scenario
    ADD CONSTRAINT disruption_scenario_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store_location(store_id);


--
-- TOC entry 4933 (class 2606 OID 16889)
-- Name: forecast_output forecast_output_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forecast_output
    ADD CONSTRAINT forecast_output_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.product(sku_id);


--
-- TOC entry 4934 (class 2606 OID 16894)
-- Name: forecast_output forecast_output_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.forecast_output
    ADD CONSTRAINT forecast_output_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store_location(store_id);


--
-- TOC entry 4929 (class 2606 OID 16853)
-- Name: inventory inventory_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.product(sku_id);


--
-- TOC entry 4930 (class 2606 OID 16858)
-- Name: inventory inventory_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store_location(store_id);


--
-- TOC entry 4935 (class 2606 OID 16907)
-- Name: macro_indicators macro_indicators_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.macro_indicators
    ADD CONSTRAINT macro_indicators_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store_location(store_id);


--
-- TOC entry 4931 (class 2606 OID 16871)
-- Name: promotion promotion_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.product(sku_id);


--
-- TOC entry 4932 (class 2606 OID 16876)
-- Name: promotion promotion_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store_location(store_id);


--
-- TOC entry 4927 (class 2606 OID 16835)
-- Name: sales_data sales_data_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_data
    ADD CONSTRAINT sales_data_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.product(sku_id);


--
-- TOC entry 4928 (class 2606 OID 16840)
-- Name: sales_data sales_data_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_data
    ADD CONSTRAINT sales_data_store_id_fkey FOREIGN KEY (store_id) REFERENCES public.store_location(store_id);


--
-- TOC entry 4937 (class 2606 OID 16941)
-- Name: social_trends social_trends_sku_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.social_trends
    ADD CONSTRAINT social_trends_sku_id_fkey FOREIGN KEY (sku_id) REFERENCES public.product(sku_id);


-- Completed on 2026-04-11 09:59:46

--
-- PostgreSQL database dump complete
--

\unrestrict mUwx2bH1hZ8u04bP1biZMefS0VoXYBMc26DCLHbortZw0DM4TYoadrBAnSCpeOY

