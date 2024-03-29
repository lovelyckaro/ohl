# Anteckningar Øhlprovnings-site
## Systembolagets api
Man kan få fetmycket information om produkterna genom en enkel `Product_search` utifrån den informationen kan man hitta länk till systembolaget för produkten genom formatet:
```php
beta.systembolaget.se/produkt/$Category/$ProductNameBold-$ProductNumberShort
```
Bilden kan länkas med följande format:
```php
beta-cdn.systembolaget.se/productimage/productimages/$productId/$ProductId.png
```
`$category` & `$ProductNameBold` är case insensitive och kan ta både det svenska namnet, (Ex. `Öl`) och samma namn utan svenska bokstäver (Ex. `Ol`). Båda har kan använda space eller bindestreck som avskiljare mellan ord (Ex. `cider-blanddrycker` eller `cider blanddrycker`).
Systembolaget själva använder konsekvent versionerna utan stora eller svenska bokstäver och med bindestreck<br>
Exempel på en typisk länk:
```php
beta.systembolaget.se/produkt/cider-blanddrycker/kiviks-ekologisk-appelcider-181403
```
Den skulle också kunna skrivas:
```php
beta.systembolaget.se/produkt/cider blanddrycker/kiviks ekologisk äppelcider-181403
```
Notera att strecket framför `ProductNumberShort` är nödvändigt
## Hantera datan i drupal
* Göra en entity för systembolaget-drycker?
* Ska øhlprovningen vara en vy av drycker? Eller en content-type med en lista av drycker?
* Ska datan cachas lokalt eller ska varje ny dryck göra en ny förfrågan till API:n?
* 


## Önskat beteende
1. Användare på siten skapar nytt content av typen øhlprovning. I ett ett form kan hen söka på drycker ur systembolagets utbud och välja ut drycker en och en. øhlprovningen kan sedan visas som en listning av ölerna i øhlprovningen.
2. øhlprovningen får en slumpad, svårgissad länk som lägger sig på skaparens profil och \<front>, denna kan delas med skaparens kompisar som kommer åt øhlprovningen utan konto.
3. På varje dryck i øhlprovningen bör man kunna ge ett betyg, se medelbetyg och (kanske) kunna lämna en kommentar.