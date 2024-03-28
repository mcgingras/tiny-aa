import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen p-24">
      <h1>Welcome to tiny-aa</h1>
      <Link href="/1">Part 1: EOA</Link>
    </main>
  );
}
