"use client";

import { ConnectKitButton } from "connectkit";
import Link from "next/link";

const Nav = () => {
  return (
    <nav className="flex flex-row justify-between items-center text-neutral-600 min-h-[56px]">
      <ul className="flex flex-row space-x-6">
        <li>
          <Link href="/" className="text-black font-bold">
            Tiny AA
          </Link>
        </li>
      </ul>
      <div className="flex flex-row items-center space-x-4">
        <ConnectKitButton theme="nouns" />
      </div>
    </nav>
  );
};

export default Nav;
