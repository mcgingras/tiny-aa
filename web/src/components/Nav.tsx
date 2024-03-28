"use client";

import { ConnectKitButton } from "connectkit";
import Link from "next/link";

const Nav = () => {
  return (
    <div className="w-full p-2">
      <nav className="px-4 py-2 flex flex-row justify-between items-center bg-white text-neutral-600 min-h-[56px]">
        <ul className="flex flex-row space-x-6">
          <li>
            <Link href="/" className="text-blue-500 font-bold">
              tiny aa
            </Link>
          </li>
        </ul>
        <div className="flex flex-row items-center space-x-4">
          <ConnectKitButton />
        </div>
      </nav>
    </div>
  );
};

export default Nav;
