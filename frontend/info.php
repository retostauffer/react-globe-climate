<!DOCTYPE HTML>
<html>
  <head>
    <script src="js/jquery.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <link href="css/bootstrap.min.css" rel="stylesheet" />

    <style>
      body {
          background-color: black;
          color: white;
      }
      .tab-pane img {
          width: 100%;
      }
      img.info-globe {
        max-width: 90%;
      }
      img.timeseries-plot {
        width: 100%;
        max-width: 1200px;
        padding: 1em 3em;
      }
      h4 { font-weight: bold; }
    </style>

    <title>ERA5 Visualization</title>
  </head>
<body id="details-content">

    <h3>Einleitende Worte</h3>

    <p>Klima interaktiv erforschen ist eine kleine Web-Anwendung in welcher Gross und Klein das Klima unserer Erde und dessen Veränderung über die vergangenen 40 Jahre (seit 1979) erforschen können.</p>

    <p>Die Änderung des Klimas ist in der aktuellen Zeit ein sehr wichtiges Thema und wird in den Medien und an Schulen immer wieder aufgegriffen. Immer wieder wird über neue Rekordtemperaturen, Starkniederschläge, Dürren und Sturmereignisse berichtet. Dass sich das Klima verändert und wir Menschen einen Einfluss auf unser Klima haben ist nicht mehr von der Hand zu weisen. So schreibt der Weltklimarat im neuesten wissenschaftlichen Bericht: “Es ist unbestreitbar, dass der Mensch die Atmosphäre, die Ozeane und das Land erwärmt hat. Weitreichende und schnelle Veränderungen in der Atmosphäre, den Ozeanen, der Kryosphäre und der Biosphäre haben bereits stattgefunden.” (<a href="#ipcc">IPCC AR6</a>).</p>

    <p>Aufgrund der Komplexität unserer Atmosphäre und da sich das Klima nur langsam verändert ist es für uns jedoch oft schwierig, das gesamte Ausmass der Klimaveränderung zu erfassen. Diese Web-Anwendung bereitet die Daten der letzten 40 Jahre grafisch auf und erlaubt es jedem und jeder, das Klima unseres Planeten interaktiv zu erkunden und zu erforschen.</p>

    <h3>Was ist eigentlich Klima?</h3>

    <p>Das Klima beschreibt den durchschnittlichen Zustand unserer Atmosphäre über einen längeren Zeitraum, beispielsweise die durchschnittliche Temperatur eines Monats oder gar eines Jahres und darf nicht mit Wetter oder gar Witterung verwechselt werden. Ein, zwei sehr warme oder sehr nasse Tage beschreiben Wetter, können aber innerhalb eines Monats durch relativ kühle oder trockene Tage wieder ausgeglichen werden.</p>

    <p>Das Klima kann von Ort zu Ort verschieden sein, eine mögliche Veränderung muss auch immer relativ zum Ort betrachtet werden. So sind Monate mit einer mittleren Temperatur von unter -10 Grad Celsius für Island im Winter nichts ungewöhnliches, genauso wie Monate mit 28 Grad Celsius oder mehr an der Afrikanischen Goldküste. Beides wäre hingegen für Wien aber bereits extrem.</p>

    <h3>Abweichungen zum langjährigen mittleren Klima</h3>

    <p>Um mögliche Veränderungen im Klima zu untersuchen werden Abweichungen zu einem langjährigen Mittel für einen bestimmten Ort berechnet, sogenannte Anomalien. Das langjährige Mittel wird dabei typischerweise über eine Periode von 30 oder mehr Jahre definiert, in dieser Anwendung von 1991 bis 2020. Zur Veranschaulichung: Lag die mittlere Temperatur an einem Ort von 1991-2020 bei +10 Grad Celsius, im Jahre 2021 bei +10.5 Grad Celsius sehen wir eine Anomalie von +0.5 Grad Celsius.</p>

    <p>Eine positive Abweichung vom langjährigen Mittel (Anomalie) bei der Temperatur weist auf eine warme Periode hin, eine negative Abweichung vom langjährigen Mittel beim Niederschlag (Schnee und Regen) auf eine Periode in der es – verglichen zur Referenzperiode – eher trocken war.</p>

    <h3>Was wird dargestellt?</h3>

    <h4>Darstellung auf dem Globus</h4>

    <div class="container-fluid">
        <div class="row">
            <div class="col-sm-1">
                <img class="info-globe" src="images/info_globe_2t.png" />
            </div>
            <div class="col-sm-11">
                <h4>Temperatur</h4>
                <p>
                    Temperatur der trockenen Luft in rund 2 Metern über dem Erdboden beziehungsweise über der Erdoberfläche, dies
                    entspricht der Temperatur aus der Wettervorhersage aus Zeitung, Radio, und TV.
                </p>
                <p>
                    Dargestellt ist jedoch nicht die Temperatur an einem gewissen Tag zu einer gewissen Uhrzeit, sondern
                    die Abweichung der mittleren Temperatur über den gesamten Monat (Tag und Nacht) zum langjährigen
                    Mittel (Refernz 1991-2020).
                </p>
                <p>
                    <ul>
                        <li><b>Rottöne (positiv):</b> wärmer</li>
                        <li><b>Blautöne (negativ):</b> kühler</li>
                    </ul>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-1">
                <img class="info-globe" src="images/info_globe_tp.png" />
            </div>
            <div class="col-sm-11">
                <h4>Niederschlag</h4>
                <p>
                    Die Niederschlagsmenge, also die Menge an Wasser aus Regen und Schnee in Millimetern pro Tag
                    (=Liter pro Quadratmeter pro Tag).
                    Dies entspricht etwa der Menge die bei leichtem Nieselregen in einer Stunde fällt.
                </p>
                <p>
                    Dargestellt ist die Abweichung (mm/Tag) des mittleren Tagesniederschlages berechnet über
                    den gesamten Monat zum langjährigen Mittelwert (Referenz 1991-2020).
                </p>
                <p>
                    <ul>
                        <li><b>Brauntöne (positiv):</b> trockener</li>
                        <li><b>Blautöne (negativ):</b> feuchter</li>
                    </ul>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-1">
                <img class="info-globe" src="images/info_globe_ci.png" />
            </div>
            <div class="col-sm-11">
                <h4>Meereseis</h4>
                <p>
                    Abnahme beziehungsweise Zunahme der Meereisbedeckung in Prozent.
                    Eine geschlossene Eisdecke entspricht 100% Eisbedeckung, offenes
                    Wasserflächen haben 0% Eisbedeckung.
                </p>
                <p>
                    Dargestellt ist die Änderung der Meereisbedeckung in Prozent
                    relativ zur Referenzperiode. Ein Wert von -100% bedeutet,
                    dass eine (in der Referenzperiode) komplett von Eis bedeckte
                    Fläche komplett offen ist. Dieser Wert kann natürlich nur erreicht
                    werde, wenn die Fläche einst (in der Referenzperiode) komplett
                    von Eis bedeckt war.
                </p>
                <p>
                    <ul>
                        <li><b>Brauntöne (negativ):</b> Eisverlust</li>
                        <li><b>Blautöne (positiv):</b> Eiszuwachs</li>
                    </ul>
                </p>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-1">
                <img class="info-globe" src="images/info_globe_swvl1.png" />
            </div>
            <div class="col-sm-11">
                <h4>Bodenfeuchte</h4>
                <p>
                    Menge an Wasser in der oberflächennahen Erdschicht (7cm) in Kubikmeter/Kubikmeter.
                    Diese Schicht ist wichtig für die Landwirtschaft beziehungsweise für das Wachstum von
                    Pflanzen deren Wurzeln nicht tief in die Erde reichen.
                </p>
                <p>
                    Abgebildet ist die Änderung des Wassergehaltes relativ zur Referenz 1991-2020.
                </p>
                <p>
                    <ul>
                        <li><b>Rottöne (negativ):</b> tockener</li>
                        <li><b>Blautöne (positiv):</b> feuchter</li>
                    </ul>
                </p>
            </div>
        </div>
    </div>

    <h4>Zeitreihen</h4>

    <p>
    Die Hauptstädte der Länder unserer Erde (weisse Punkte auf dem Globus) können angeklickt werden.
    Wo möglich stehen die Daten als Zeitreihen zur Verfügung für Temperatur, Niederschlag, sowie Bodenfeuchte.
    </p>

    <p>
    Der obere Teil der Grafik zeigt die Absolutwerte (bei Temperatur in Grad Celsius), wobei die Linie
    den Monatsmitteln entspricht, die Punkte stellen den Mittelwert über das gesamte Jahr dar.
    Der untere Teil der Grafik zeigt die Anomalien, also die Abweichung der Monatsmittel (Linie) beziehungsweise
    Jahresmittel (Balken) im Vergleich zur Referenzperiode 1991-2020.
    </p>
   
    <p>
        <div class="container-fluid">
        <img class="timeseries-plot" src="images/example_timeseries.svg" />
        </div>
    </p>



    <h3>Datengrundlage</h3>

    <p>Alle Visualisierungen basieren auf <a href="#hersbach">ERA5</a>, einer globalen Reanalyse des Europäischen Wettervorhersagezentrums welches in Zusammenarbeit mit der Europäischen Kommission und Copernicus über den <a href="#cds">Climate Data Store</a> für jede*n frei zugänglich ist.</p>

    <p>
    Die horizontale Auflösung der Analyse liegt bei 0.25 Grad x 0.25 Grad, in der nähe des Äquators entspricht dies rund 32km x 32km.
    Diese Vereinfachung hat mehrere technische und praktische Gründe, eine Verdopplung der horizontalen Auflösung führt zwangsweise
    zu einer Vervierfachung der Datenmenge, welche jetzt schon bei rund 10 Petabyte liegt (=zehntausend Terrabyte oder zehn Millionen Gigabyte), ein durchschnittlicher
    Computer für den Privatgebrauch hat Heute meist 1-4 Terrabyte an Speicherplatz.
    </p>

    <h3>Referenzen und Links</h3>
    <ul>
        <li id="ipcc">IPCC (2022): Summary for Policymakers, <a href="https://www.ipcc.ch/report/ar6/wg1/downloads/report/IPCC_AR6_WGI_SPM.pdf">weblink</a>
        <li id="hersbach">ERA5: Hersbach, H. et al. (2018): ERA5 hourly data on single levels from 1979 to present. Copernicus Climate Change Service (C3S) Climate Data Store (CDS), <a href="https://doi.org/10.24381/cds.adbb2d47">doi:10.24381/cds.adbb2d47</a>.
        <li id="cds">ERA5 Climate Variability Data: Frei zug&auml;nglich &uuml;ber den <a href="https://cds.climate.copernicus.eu/cdsapp#!/dataset/ecv-for-climate-change?tab=form">Climate Data Store</a>.
    </ul>
</body>

</html>


