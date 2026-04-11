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

