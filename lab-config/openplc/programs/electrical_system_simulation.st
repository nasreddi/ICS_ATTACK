PROGRAM ElectricalSystemSimulation
VAR
    // Variables de génération - Centrale Thermique Nord (Unit ID 1)
    Gen1_Power : REAL;           // Puissance générateur 1 (MW)
    Gen1_Voltage : REAL;         // Tension générateur 1 (kV)
    Gen1_Current : REAL;         // Courant générateur 1 (A)
    Gen1_Frequency : REAL;       // Fréquence générateur 1 (Hz)
    Gen1_Status : BOOL;          // Statut générateur 1 (ON/OFF)
    Gen1_Trip : BOOL;            // Déclenchement générateur 1
    
    // Variables de génération - Centrale Solaire Sud (Unit ID 2)
    Gen2_Power : REAL;           // Puissance générateur 2 (MW)
    Gen2_Voltage : REAL;         // Tension générateur 2 (kV)
    Gen2_Current : REAL;         // Courant générateur 2 (A)
    Gen2_Status : BOOL;          // Statut générateur 2 (ON/OFF)
    Solar_Irradiance : REAL;     // Irradiance solaire (W/m²)
    
    // Variables transmission HTB (Unit ID 3)
    HTB_Voltage_400kV : REAL;    // Tension HTB 400kV (kV)
    HTB_Current_400kV : REAL;    // Courant HTB 400kV (A)
    HTB_Power_400kV : REAL;      // Puissance HTB 400kV (MW)
    HTB_Breaker_400kV : BOOL;    // Disjoncteur HTB 400kV
    HTB_Protection : BOOL;       // Protection HTB
    
    // Variables distribution HTA 1 (Unit ID 4)
    HTA_Voltage_20kV : REAL;     // Tension HTA 20kV (kV)
    HTA_Current_20kV : REAL;     // Courant HTA 20kV (A)
    Transformer_1_Power : REAL;  // Puissance transformateur 1 (MVA)
    Transformer_1_Temp : REAL;   // Température transformateur 1 (°C)
    HTA_Breaker_20kV : BOOL;     // Disjoncteur HTA 20kV
    
    // Variables distribution HTA 2 (Unit ID 5)
    HTA2_Voltage_20kV : REAL;    // Tension HTA2 20kV (kV)
    Transformer_2_Power : REAL;  // Puissance transformateur 2 (MVA)
    Transformer_2_Temp : REAL;   // Température transformateur 2 (°C)
    
    // Variables charges consommateurs (Unit ID 6, 7, 8)
    Load1_Power : REAL;          // Puissance charge 1 (MW)
    Load1_Voltage : REAL;        // Tension charge 1 (kV)
    Load1_Current : REAL;        // Courant charge 1 (A)
    Load1_Status : BOOL;         // Statut charge 1 (ON/OFF)
    
    Load2_Power : REAL;          // Puissance charge 2 (MW)
    Load2_Voltage : REAL;        // Tension charge 2 (kV)
    Load2_Status : BOOL;         // Statut charge 2 (ON/OFF)
    
    Load3_Power : REAL;          // Puissance charge 3 (MW)
    Load3_Voltage : REAL;        // Tension charge 3 (kV)
    Load3_Status : BOOL;         // Statut charge 3 (ON/OFF)
    
    // Variables de simulation
    Simulation_Time : REAL;      // Temps de simulation
    Random_Factor : REAL;        // Facteur aléatoire
    Day_Night_Cycle : REAL;      // Cycle jour/nuit
    Temperature_Ambient : REAL;  // Température ambiante
    
    // Compteurs et timers
    Counter : INT;
    Timer_1s : TON;
    Timer_5s : TON;
    Timer_1min : TON;
    
    // Variables de calcul
    Total_Generation : REAL;
    Total_Consumption : REAL;
    Power_Balance : REAL;
    System_Frequency : REAL;
    
END_VAR

// Initialisation des variables
Gen1_Status := TRUE;
Gen2_Status := TRUE;
HTB_Breaker_400kV := TRUE;
HTA_Breaker_20kV := TRUE;
Load1_Status := TRUE;
Load2_Status := TRUE;
Load3_Status := TRUE;
Gen1_Trip := FALSE;
HTB_Protection := FALSE;

// Timers
Timer_1s(IN := TRUE, PT := T#1s);
Timer_5s(IN := TRUE, PT := T#5s);
Timer_1min(IN := TRUE, PT := T#1min);

// Simulation du temps et facteurs aléatoires
IF Timer_1s.Q THEN
    Counter := Counter + 1;
    Simulation_Time := Simulation_Time + 1.0;
    Random_Factor := SIN(Simulation_Time * 0.1) * 0.1 + 1.0;
    Day_Night_Cycle := (SIN(Simulation_Time * 0.001) + 1.0) / 2.0;
    Temperature_Ambient := 20.0 + SIN(Simulation_Time * 0.0005) * 10.0;
END_IF;

// === CENTRALE THERMIQUE NORD (Unit ID 1) ===
// Simulation générateur 1
IF Gen1_Status AND NOT Gen1_Trip THEN
    Gen1_Power := 150.0 + SIN(Simulation_Time * 0.01) * 20.0 * Random_Factor;
    Gen1_Voltage := 400.0 + SIN(Simulation_Time * 0.02) * 5.0;
    Gen1_Current := Gen1_Power * 1000.0 / (Gen1_Voltage * 1.732);
    Gen1_Frequency := 50.0 + SIN(Simulation_Time * 0.005) * 0.2;
ELSE
    Gen1_Power := 0.0;
    Gen1_Voltage := 0.0;
    Gen1_Current := 0.0;
    Gen1_Frequency := 0.0;
END_IF;

// Simulation déclenchement générateur 1 (aléatoire)
IF Timer_5s.Q AND (RAND() MOD 1000) < 1 THEN
    Gen1_Trip := TRUE;
END_IF;

// === CENTRALE SOLAIRE SUD (Unit ID 2) ===
// Simulation générateur 2 (solaire)
IF Gen2_Status THEN
    Solar_Irradiance := 800.0 * Day_Night_Cycle + SIN(Simulation_Time * 0.02) * 100.0;
    Gen2_Power := Solar_Irradiance * 0.2 * Random_Factor;
    Gen2_Voltage := 400.0 + SIN(Simulation_Time * 0.015) * 3.0;
    Gen2_Current := Gen2_Power * 1000.0 / (Gen2_Voltage * 1.732);
ELSE
    Gen2_Power := 0.0;
    Gen2_Voltage := 0.0;
    Gen2_Current := 0.0;
    Solar_Irradiance := 0.0;
END_IF;

// === POSTE TRANSMISSION HTB (Unit ID 3) ===
// Simulation transmission HTB
IF HTB_Breaker_400kV AND NOT HTB_Protection THEN
    HTB_Voltage_400kV := 400.0 + SIN(Simulation_Time * 0.01) * 2.0;
    HTB_Current_400kV := (Gen1_Current + Gen2_Current) * 0.1;
    HTB_Power_400kV := Gen1_Power + Gen2_Power;
ELSE
    HTB_Voltage_400kV := 0.0;
    HTB_Current_400kV := 0.0;
    HTB_Power_400kV := 0.0;
END_IF;

// Simulation protection HTB (aléatoire)
IF Timer_1min.Q AND (RAND() MOD 10000) < 1 THEN
    HTB_Protection := TRUE;
END_IF;

// === POSTE DISTRIBUTION HTA 1 (Unit ID 4) ===
// Simulation distribution HTA 1
IF HTA_Breaker_20kV THEN
    HTA_Voltage_20kV := 20.0 + SIN(Simulation_Time * 0.02) * 0.5;
    HTA_Current_20kV := HTB_Current_400kV * 20.0;
    Transformer_1_Power := HTB_Power_400kV * 0.8;
    Transformer_1_Temp := Temperature_Ambient + (Transformer_1_Power * 0.5) + SIN(Simulation_Time * 0.01) * 2.0;
ELSE
    HTA_Voltage_20kV := 0.0;
    HTA_Current_20kV := 0.0;
    Transformer_1_Power := 0.0;
    Transformer_1_Temp := Temperature_Ambient;
END_IF;

// === POSTE DISTRIBUTION HTA 2 (Unit ID 5) ===
// Simulation distribution HTA 2
HTA2_Voltage_20kV := HTA_Voltage_20kV * 0.95;
Transformer_2_Power := Transformer_1_Power * 0.6;
Transformer_2_Temp := Temperature_Ambient + (Transformer_2_Power * 0.4) + SIN(Simulation_Time * 0.012) * 1.5;

// === CHARGES CONSOMMATEURS ===
// Charge industrielle Nord (Unit ID 6)
IF Load1_Status THEN
    Load1_Power := 25.0 + SIN(Simulation_Time * 0.03) * 5.0 * Random_Factor;
    Load1_Voltage := 0.4 + SIN(Simulation_Time * 0.025) * 0.02;
    Load1_Current := Load1_Power * 1000.0 / (Load1_Voltage * 1.732);
ELSE
    Load1_Power := 0.0;
    Load1_Voltage := 0.0;
    Load1_Current := 0.0;
END_IF;

// Charge résidentielle Sud (Unit ID 7)
IF Load2_Status THEN
    Load2_Power := 15.0 * Day_Night_Cycle + SIN(Simulation_Time * 0.04) * 3.0 * Random_Factor;
    Load2_Voltage := 0.4 + SIN(Simulation_Time * 0.03) * 0.015;
ELSE
    Load2_Power := 0.0;
    Load2_Voltage := 0.0;
END_IF;

// Charge commerciale Centre (Unit ID 8)
IF Load3_Status THEN
    Load3_Power := 20.0 * (1.0 - Day_Night_Cycle * 0.3) + SIN(Simulation_Time * 0.035) * 4.0 * Random_Factor;
    Load3_Voltage := 0.4 + SIN(Simulation_Time * 0.028) * 0.018;
ELSE
    Load3_Power := 0.0;
    Load3_Voltage := 0.0;
END_IF;

// === CALCULS SYSTÈME ===
Total_Generation := Gen1_Power + Gen2_Power;
Total_Consumption := Load1_Power + Load2_Power + Load3_Power;
Power_Balance := Total_Generation - Total_Consumption;
System_Frequency := Gen1_Frequency;

// === ASSIGNATION AUX SORTIES MODBUS ===
// Unit ID 1 - Centrale Thermique Nord
%QW0 := REAL_TO_WORD(Gen1_Power * 10.0);
%QW2 := REAL_TO_WORD(Gen1_Voltage * 10.0);
%QW4 := REAL_TO_WORD(Gen1_Current * 10.0);
%QW6 := REAL_TO_WORD(Gen1_Frequency * 100.0);
%QX0.0 := Gen1_Status;
%QX0.1 := Gen1_Trip;

// Unit ID 2 - Centrale Solaire Sud
%QW8 := REAL_TO_WORD(Gen2_Power * 10.0);
%QW10 := REAL_TO_WORD(Gen2_Voltage * 10.0);
%QW12 := REAL_TO_WORD(Gen2_Current * 10.0);
%QW14 := REAL_TO_WORD(Solar_Irradiance * 10.0);
%QX0.2 := Gen2_Status;

// Unit ID 3 - Poste Transmission HTB
%QW16 := REAL_TO_WORD(HTB_Voltage_400kV * 10.0);
%QW18 := REAL_TO_WORD(HTB_Current_400kV * 10.0);
%QW20 := REAL_TO_WORD(HTB_Power_400kV * 10.0);
%QX0.3 := HTB_Breaker_400kV;
%QX0.4 := HTB_Protection;

// Unit ID 4 - Poste Distribution HTA 1
%QW22 := REAL_TO_WORD(HTA_Voltage_20kV * 10.0);
%QW24 := REAL_TO_WORD(HTA_Current_20kV * 10.0);
%QW26 := REAL_TO_WORD(Transformer_1_Power * 10.0);
%QW28 := REAL_TO_WORD(Transformer_1_Temp * 10.0);
%QX0.5 := HTA_Breaker_20kV;

// Unit ID 5 - Poste Distribution HTA 2
%QW30 := REAL_TO_WORD(HTA2_Voltage_20kV * 10.0);
%QW32 := REAL_TO_WORD(Transformer_2_Power * 10.0);
%QW34 := REAL_TO_WORD(Transformer_2_Temp * 10.0);

// Unit ID 6 - Charge Industrielle Nord
%QW36 := REAL_TO_WORD(Load1_Power * 10.0);
%QW38 := REAL_TO_WORD(Load1_Voltage * 1000.0);
%QW40 := REAL_TO_WORD(Load1_Current * 10.0);
%QX0.6 := Load1_Status;

// Unit ID 7 - Charge Résidentielle Sud
%QW42 := REAL_TO_WORD(Load2_Power * 10.0);
%QW44 := REAL_TO_WORD(Load2_Voltage * 1000.0);
%QX0.7 := Load2_Status;

// Unit ID 8 - Charge Commerciale Centre
%QW46 := REAL_TO_WORD(Load3_Power * 10.0);
%QW48 := REAL_TO_WORD(Load3_Voltage * 1000.0);
%QX1.0 := Load3_Status;

END_PROGRAM
