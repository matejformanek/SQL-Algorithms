create table flights (
  flight_id character varying(30),
  "start" character varying(20),
  dest character varying(20),
  cost integer);

insert into flights values ('f1','SF','LA',50);
insert into flights values ('f2','LA','SF',50);
insert into flights values ('f3','SF','CH',275);
insert into flights values ('f4','CH','SF',275);
insert into flights values ('f5','SF','DA',300);
insert into flights values ('f6','DA','SF',300);
insert into flights values ('f7','CH','DA',100);
insert into flights values ('f8','DA','CH',100);
insert into flights values ('f9','CH','NY',250);
insert into flights values ('f10','NY','CH',250);
insert into flights values ('f11','NY','DA',225);
insert into flights values ('f12','DA','NY',225);
insert into flights values ('f13','DA','LA',200);
insert into flights values ('f14','LA','DA',200);
INSERT INTO flights VALUES ('f15','NY','PRG',15000);
INSERT INTO flights VALUES ('f16','PRG','BNO',30);