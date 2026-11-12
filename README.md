
<!DOCTYPE html>
<html lang="sl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Moj Šparovček – Matic & Nives</title>
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<style>
*{box-sizing:border-box}
body{margin:0;background:#f3f6f2;color:#24352b;font-family:Arial,sans-serif;padding:18px}
main{max-width:520px;margin:auto}
h1{text-align:center;color:#26734d;font-size:26px}
.card{background:white;border-radius:18px;padding:18px;margin:14px 0;box-shadow:0 3px 14px #0000000c}
input,select,button{width:100%;padding:13px;margin:6px 0;border:1px solid #d5ded7;border-radius:10px;font-size:16px}
button{background:#26734d;color:white;border:0;font-weight:bold}
button.secondary{background:#e7f1e9;color:#26734d}
button.danger{background:#a33b36}
.total{font-size:27px;font-weight:bold;color:#26734d}
.small{font-size:13px;color:#66756b}
.item{border-bottom:1px solid #e8eee9;padding:12px 0}
.item:last-child{border:0}
.hidden{display:none}
.row{display:flex;gap:8px}
.row>*{flex:1;min-width:0}
</style>
</head>
<body>
<main>
<h1>🐷 Moj Šparovček</h1>
<p style="text-align:center">Matic & Nives</p>

<section class="card" id="login">
<h3>Prijava ali registracija</h3>
<input id="email" type="email" placeholder="E-poštni naslov">
<input id="password" type="password" placeholder="Geslo">
<button onclick="signIn()">Prijava</button>
<button class="secondary" onclick="signUp()">Ustvari račun</button>
<p class="small" id="loginMsg">Vsak naj ustvari svoj račun s svojim e-poštnim naslovom.</p>
</section>

<section class="card hidden" id="house">
<h3>Skupna blagajna</h3>
<p>Ustvari novo blagajno ali se pridruži obstoječi.</p>
<input id="houseName" placeholder="Ime blagajne (npr. Matic in Nives)">
<button onclick="createHouse()">Ustvari blagajno</button>
<hr>
<input id="inviteCode" placeholder="Koda za pridružitev">
<button class="secondary" onclick="joinHouse()">Pridruži se blagajni</button>
<p class="small" id="houseMsg"></p>
</section>

<section class="hidden" id="app">
<div class="card">
<h3 id="houseTitle">Najina blagajna</h3>
<p class="small">Skupno stanje</p>
<div class="total" id="balance">0,00 €</div>
<div class="row">
<div><p class="small">Prihodki</p><strong id="incomeTotal">0,00 €</strong></div>
<div><p class="small">Stroški</p><strong id="expenseTotal">0,00 €</strong></div>
</div>
<p class="small" id="inviteDisplay"></p>
</div>

<div class="card">
<h3>Dodaj vnos</h3>
<select id="kind">
<option value="expense">Strošek</option>
<option value="income">Prihodek</option>
</select>
<input id="amount" type="number" min="0.01" step="0.01" placeholder="Znesek v €">
<input id="description" placeholder="Opis (npr. trgovina, plača)">
<select id="category">
<option>Hrana</option><option>Stanovanje</option><option>Prevoz</option>
<option>Položnice</option><option>Otroci</option><option>Zdravje</option>
<option>Zabava</option><option>Plača</option><option>Drugo</option>
</select>
<button onclick="addEntry()">Shrani vnos</button>
<button class="secondary" onclick="voiceEntry()">🎙️ Glasovni vnos</button>
<p class="small" id="voiceMsg">Glasovni vnos je odvisen od podpore brskalnika.</p>
</div>

<div class="card">
<h3>Najini vnosi</h3>
<div id="entries">Nalaganje ...</div>
</div>
<button class="danger" onclick="signOut()">Odjava</button>
</section>
</main>

<script>
const SUPABASE_URL =
