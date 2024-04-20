import React  from 'react';
import styles from '../styles/Home.module.css';

export default function Home() {
  return (
    <div className={styles.container}>
      

      <main className={styles.main}>
        <h1 className={styles.title}>
          Merhaba, Motor Tutkunu
        </h1>

        <p className={styles.description}>
          Motor Kiralamaya hazır mısın
        </p>
      </main>

      <footer className={styles.footer}>
        Next.js ile oluşturulmuştur.
      </footer>

      <img src="/image.jpg" alt="Büyük Görsel" className={styles.image} />

    </div>
  );
}