function delay(ms: number): Promise<void> {
  return new Promise((res) => {
    setTimeout(() => res(), ms);
  });
}

Deno.serve(async (req) => {
  const url = new URL(req.url);
  if (url.pathname == "/%D0%A6%D0%98%D0%A1-15") {
    await delay(2000);
    return new Response(Deno.openSync("cis-15.json").readable, {
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response("", { status: 404 });
});
