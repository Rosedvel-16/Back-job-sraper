from flask import Flask, request, jsonify
from flask_cors import CORS
from scraper import scrape_computrabajo, scrape_bumeran

app = Flask(__name__)
CORS(app)

@app.route('/api/search', methods=['GET'])
def search_jobs():
    print("Petición recibida en /api/search")

    cargo = request.args.get('cargo', default='', type=str)
    distrito = request.args.get('distrito', default='', type=str)
    sueldo_min = request.args.get('sueldo_min', default=None, type=int)
    sueldo_max = request.args.get('sueldo_max', default=None, type=int)
    fuente = request.args.get('fuente', default='todos', type=str)
    
    experiencia_str = request.args.get('experiencia', default=None, type=str)
    experiencia = int(experiencia_str) if experiencia_str is not None else None

    jornada = request.args.get('jornada', default=None, type=str)
    max_paginas = 3

    print(f"Filtros: cargo='{cargo}', distrito='{distrito}', sueldo_min={sueldo_min}, sueldo_max={sueldo_max}, experiencia={experiencia}, jornada={jornada}, fuente='{fuente}'")

    todas_ofertas = []

    # Lógica condicional para llamar a los scrapers
    if fuente in ['todos', 'computrabajo']:
        try:
            print("Iniciando scraping en Computrabajo...")
            ofertas_ct = scrape_computrabajo(
                cargo=cargo, distrito=distrito, sueldo_min=sueldo_min,
                sueldo_max=sueldo_max, experiencia=experiencia,
                jornada=jornada, max_paginas=max_paginas
            )
            for o in ofertas_ct:
                o["Fuente"] = "Computrabajo"
            todas_ofertas.extend(ofertas_ct)
            print(f"Computrabajo finalizado. Se encontraron {len(ofertas_ct)} ofertas.")
        except Exception as e:
            print(f"Error en Computrabajo: {e}")

    if fuente in ['todos', 'bumeran']:
        try:
            print("Iniciando scraping en Bumeran...")
            ofertas_bm = scrape_bumeran(
                cargo=cargo, distrito=distrito, sueldo_min=sueldo_min,
                sueldo_max=sueldo_max, experiencia=experiencia,
                max_paginas=max_paginas
            )
            for o in ofertas_bm:
                o["Fuente"] = "Bumeran"
            todas_ofertas.extend(ofertas_bm)
            print(f"Bumeran finalizado. Se encontraron {len(ofertas_bm)} ofertas.")
        except Exception as e:
            print(f"Error en Bumeran: {e}")

    print(f"Búsqueda completada. Total de ofertas: {len(todas_ofertas)}")
    return jsonify(todas_ofertas)

if __name__ == '__main__':
    app.run(debug=True, port=5000)