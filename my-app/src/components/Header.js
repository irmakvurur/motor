import React from 'react';
import headerStyles from "../styles/Header.module.css";
import Link from "next/link";

const Header = () => {
  return (
  <div className= {headerStyles.navbar}>
  <nav>
      <ul>
        <li className= {headerStyles.navItem}> 
          <Link href="/">
            Anasayfa
          </Link>
        </li>
        <li className= {headerStyles.navItem}>
          <Link href="/about">
            Hakkımızda
          </Link>
        </li>
      </ul>
    </nav>
   </div>
  )
}

export default Header