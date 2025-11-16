import { useState } from 'react'
import './App.css'

function App() {
  const [selectedSport, setSelectedSport] = useState(null)
  
  const sports = [
    {
      id: 1,
      name: 'Fútbol',
      icon: '⚽',
      description: 'El deporte rey, jugado por millones en todo el mundo',
      facts: ['11 jugadores por equipo', 'Campo de 90-120m de largo', 'Partidos de 90 minutos']
    },
    {
      id: 2,
      name: 'Baloncesto',
      icon: '🏀',
      description: 'Deporte de velocidad y precisión en cancha cerrada',
      facts: ['5 jugadores por equipo', 'Canasta a 3.05m de altura', 'Partidos de 48 minutos (NBA)']
    },
    {
      id: 3,
      name: 'Tenis',
      icon: '🎾',
      description: 'Deporte individual o de parejas con raqueta',
      facts: ['Individual o dobles', 'Grand Slam: 5 sets', 'Velocidad de saque: 250+ km/h']
    },
    {
      id: 4,
      name: 'Natación',
      icon: '🏊',
      description: 'Competencia de velocidad en agua',
      facts: ['4 estilos principales', 'Piscina olímpica: 50m', 'Disciplina desde 1896']
    },
    {
      id: 5,
      name: 'Atletismo',
      icon: '🏃',
      description: 'La base de todos los deportes olímpicos',
      facts: ['Carreras, saltos, lanzamientos', 'Récord 100m: 9.58s', 'El deporte más antiguo']
    },
    {
      id: 6,
      name: 'Ciclismo',
      icon: '🚴',
      description: 'Velocidad sobre dos ruedas',
      facts: ['Tour de France: 21 etapas', 'Velocidad máxima: 100+ km/h', 'Múltiples modalidades']
    }
  ]

  return (
    <div className="app">
      <header className="header">
        <h1>🏆 Portal Deportivo</h1>
        <p className="version">Versión Blue 1.0 - Despliegue Blue-Green</p>
      </header>

      <main className="main-content">
        <section className="intro">
          <h2>Explora el Mundo del Deporte</h2>
          <p>Descubre información sobre los deportes más populares del mundo</p>
        </section>

        <div className="sports-grid">
          {sports.map(sport => (
            <div 
              key={sport.id}
              className={`sport-card ${selectedSport?.id === sport.id ? 'selected' : ''}`}
              onClick={() => setSelectedSport(sport)}
            >
              <div className="sport-icon">{sport.icon}</div>
              <h3>{sport.name}</h3>
              <p>{sport.description}</p>
            </div>
          ))}
        </div>

        {selectedSport && (
          <div className="sport-details">
            <h2>{selectedSport.icon} {selectedSport.name}</h2>
            <p className="detail-description">{selectedSport.description}</p>
            <h3>Datos Interesantes:</h3>
            <ul>
              {selectedSport.facts.map((fact, index) => (
                <li key={index}>{fact}</li>
              ))}
            </ul>
            <button onClick={() => setSelectedSport(null)} className="close-btn">
              Cerrar
            </button>
          </div>
        )}
      </main>

      <footer className="footer">
        <p>© 2025 Portal Deportivo | Blue-Green Deployment Demo</p>
        <p className="env-info">Ambiente: <span className="env-blue">BLUE</span></p>
      </footer>
    </div>
  )
}

export default App
