-- PRODUCT
INSERT INTO product VALUES
('SKU001','iPhone 14','Electronics','Mobile',80000,'SUP1'),
('SKU002','Samsung TV','Electronics','TV',60000,'SUP2'),
('SKU003','Nike Shoes','Fashion','Footwear',5000,'SUP3'),
('SKU004','Adidas T-Shirt','Fashion','Clothing',2000,'SUP3'),
('SKU005','Dell Laptop','Electronics','Laptop',70000,'SUP4'),
('SKU006','HP Printer','Electronics','Printer',12000,'SUP5'),
('SKU007','Boat Earbuds','Electronics','Audio',1500,'SUP6'),
('SKU008','Puma Jacket','Fashion','Clothing',4000,'SUP3'),
('SKU009','LG Fridge','Appliances','Refrigerator',45000,'SUP7'),
('SKU010','Sony Camera','Electronics','Camera',55000,'SUP8');


-- STORE LOCATION 
INSERT INTO store_location VALUES
('ST001','Ahmedabad Store','Ahmedabad','Gujarat','India'),
('ST002','Mumbai Store','Mumbai','Maharashtra','India'),
('ST003','Delhi Store','Delhi','Delhi','India'),
('ST004','Bangalore Store','Bangalore','Karnataka','India'),
('ST005','Chennai Store','Chennai','Tamil Nadu','India'),
('ST006','Pune Store','Pune','Maharashtra','India'),
('ST007','Surat Store','Surat','Gujarat','India'),
('ST008','Jaipur Store','Jaipur','Rajasthan','India'),
('ST009','Hyderabad Store','Hyderabad','Telangana','India'),
('ST010','Kolkata Store','Kolkata','West Bengal','India');


-- SALES
INSERT INTO sales_data (sku_id, store_id, date, quantity_sold, revenue, promo_flag) VALUES
('SKU001','ST001','2026-04-01',5,400000,true),
('SKU002','ST002','2026-04-01',3,180000,false),
('SKU003','ST003','2026-04-01',10,50000,true),
('SKU004','ST004','2026-04-01',8,16000,false),
('SKU005','ST005','2026-04-01',2,140000,true),
('SKU006','ST006','2026-04-01',4,48000,false),
('SKU007','ST007','2026-04-01',15,22500,true),
('SKU008','ST008','2026-04-01',6,24000,false),
('SKU009','ST009','2026-04-01',1,45000,true),
('SKU010','ST010','2026-04-01',2,110000,false);


-- INVENTORY 
INSERT INTO inventory (sku_id, date, stock_level, reorder_point, safety_stock, restock_qty, store_id) VALUES
('SKU001','2026-04-01',50,20,10,30,'ST001'),
('SKU002','2026-04-01',40,15,8,25,'ST002'),
('SKU003','2026-04-01',100,50,20,60,'ST003'),
('SKU004','2026-04-01',80,30,15,40,'ST004'),
('SKU005','2026-04-01',30,10,5,20,'ST005'),
('SKU006','2026-04-01',60,25,10,35,'ST006'),
('SKU007','2026-04-01',120,60,25,70,'ST007'),
('SKU008','2026-04-01',70,30,15,40,'ST008'),
('SKU009','2026-04-01',20,8,4,15,'ST009'),
('SKU010','2026-04-01',25,10,5,18,'ST010');


-- PROMOTION 
INSERT INTO promotion (sku_id, store_id, start_date, end_date, discount_pct, promo_type) VALUES
('SKU001','ST001','2026-04-01','2026-04-10',10,'Festival'),
('SKU002','ST002','2026-04-02','2026-04-12',15,'Clearance'),
('SKU003','ST003','2026-04-03','2026-04-13',20,'Seasonal'),
('SKU004','ST004','2026-04-01','2026-04-05',5,'Flash'),
('SKU005','ST005','2026-04-02','2026-04-08',12,'Festival'),
('SKU006','ST006','2026-04-03','2026-04-09',8,'Clearance'),
('SKU007','ST007','2026-04-04','2026-04-14',18,'Seasonal'),
('SKU008','ST008','2026-04-01','2026-04-06',7,'Flash'),
('SKU009','ST009','2026-04-02','2026-04-11',10,'Festival'),
('SKU010','ST010','2026-04-03','2026-04-12',14,'Seasonal');


-- FORECAST OUTPUT 
INSERT INTO forecast_output (sku_id, store_id, forecast_date, horizon_days, p10, p50, p90, model_used, created_at) VALUES
('SKU001','ST001','2026-04-01',7,3,5,8,'ARIMA',NOW()),
('SKU002','ST002','2026-04-01',7,2,4,6,'ARIMA',NOW()),
('SKU003','ST003','2026-04-01',7,8,12,18,'LSTM',NOW()),
('SKU004','ST004','2026-04-01',7,5,7,10,'ARIMA',NOW()),
('SKU005','ST005','2026-04-01',7,1,2,4,'Prophet',NOW()),
('SKU006','ST006','2026-04-01',7,3,6,9,'LSTM',NOW()),
('SKU007','ST007','2026-04-01',7,10,15,20,'ARIMA',NOW()),
('SKU008','ST008','2026-04-01',7,4,6,9,'Prophet',NOW()),
('SKU009','ST009','2026-04-01',7,1,2,3,'ARIMA',NOW()),
('SKU010','ST010','2026-04-01',7,2,3,5,'LSTM',NOW());


-- MACRO INDICATORS
INSERT INTO macro_indicators (date, store_id, consumer_confidence_ind, unemp_rate, fuel_price) VALUES
('2026-04-01','ST001',98.5,5.2,102),
('2026-04-01','ST002',95.0,6.0,105),
('2026-04-01','ST003',97.2,5.5,103),
('2026-04-01','ST004',96.8,5.8,104),
('2026-04-01','ST005',94.5,6.2,106),
('2026-04-01','ST006',93.0,6.5,107),
('2026-04-01','ST007',99.1,4.8,101),
('2026-04-01','ST008',92.5,6.8,108),
('2026-04-01','ST009',91.2,7.0,109),
('2026-04-01','ST010',90.0,7.5,110);


-- WEATHER
INSERT INTO weather_data (date, location_id, temperature) VALUES
('2026-04-01','Ahmedabad',35),
('2026-04-01','Mumbai',32),
('2026-04-01','Delhi',36),
('2026-04-01','Bangalore',28),
('2026-04-01','Chennai',34),
('2026-04-01','Pune',30),
('2026-04-01','Surat',33),
('2026-04-01','Jaipur',37),
('2026-04-01','Hyderabad',31),
('2026-04-01','Kolkata',29);


-- DISRUPTION SCENARIO
INSERT INTO disruption_scenario (scenario_name, affected_region, store_id, start_date, duration_days, impact_factor, scenario_type) VALUES
('Flood','Gujarat','ST001','2026-04-01',5,0.7,'Natural'),
('Strike','Maharashtra','ST002','2026-04-02',3,0.5,'Human'),
('Heatwave','Delhi','ST003','2026-04-03',7,0.6,'Natural'),
('Rain','Karnataka','ST004','2026-04-01',2,0.3,'Natural'),
('Cyclone','Tamil Nadu','ST005','2026-04-02',6,0.8,'Natural'),
('Transport Issue','Maharashtra','ST006','2026-04-03',4,0.4,'Logistics'),
('Flood','Gujarat','ST007','2026-04-04',5,0.7,'Natural'),
('Power Cut','Rajasthan','ST008','2026-04-01',2,0.2,'Infrastructure'),
('Strike','Telangana','ST009','2026-04-02',3,0.5,'Human'),
('Storm','West Bengal','ST010','2026-04-03',4,0.6,'Natural');


-- SOCIAL TRENDS
INSERT INTO social_trends (date, sku_id, category, google_trend_index, social_media_score) VALUES
('2026-04-01','SKU001','Electronics',75,80),
('2026-04-01','SKU002','Electronics',65,70),
('2026-04-01','SKU003','Fashion',85,90),
('2026-04-01','SKU004','Fashion',60,65),
('2026-04-01','SKU005','Electronics',78,82),
('2026-04-01','SKU006','Electronics',55,60),
('2026-04-01','SKU007','Electronics',88,92),
('2026-04-01','SKU008','Fashion',70,75),
('2026-04-01','SKU009','Appliances',50,55),
('2026-04-01','SKU010','Electronics',68,72);