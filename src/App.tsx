import { Copy, Terminal, Github, Check, Download } from 'lucide-react';
import { useState, useEffect } from 'react';

export default function App() {
  const [copied, setCopied] = useState(false);
  const [copiedRaw, setCopiedRaw] = useState(false);
  const [appUrl, setAppUrl] = useState('https://your-domain.com');
  const [luaCode, setLuaCode] = useState('');

  // Dynamically get the APP_URL or fallback to the current window origin
  useEffect(() => {
    // If running in iframe, get the URL of this exact domain
    const currentUrl = window.location.origin;
    if (currentUrl) {
        setAppUrl(currentUrl);
    }
    
    // Fetch the raw Lua code to display it
    fetch('/nex.lua')
        .then(res => res.text())
        .then(text => setLuaCode(text))
        .catch(err => console.error("Failed to load lua preview:", err));
  }, []);

  const loadstringCmd = `loadstring(game:HttpGet("${appUrl}/nex.lua"))()`;

  const handleCopy = (text: string, setter: (val: boolean) => void) => {
    navigator.clipboard.writeText(text);
    setter(true);
    setTimeout(() => setter(false), 2000);
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-200 font-sans selection:bg-sky-500/30 selection:text-sky-200">
      <div className="max-w-4xl mx-auto px-6 py-12">
        {/* Header */}
        <header className="mb-16 text-center space-y-4">
          <div className="inline-flex items-center justify-center w-12 h-12 bg-sky-500 rounded-lg mb-4 shadow-[0_0_15px_rgba(56,189,248,0.4)]">
            <Terminal className="w-6 h-6 text-slate-900" strokeWidth={2.5} />
          </div>
          <h1 className="text-4xl md:text-5xl font-bold text-white tracking-tight">Nex Library</h1>
          <p className="text-lg md:text-xl text-slate-400 max-w-2xl mx-auto">
            A minimal, lightweight, and powerful utility library for Roblox exploiting and UI creation.
          </p>
        </header>

        {/* Quick Start Loadstring */}
        <section className="mb-12">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-2xl font-semibold text-white tracking-tight">Quick Start</h2>
            <span className="text-xs font-mono px-3 py-1.5 bg-slate-800 border border-slate-700 rounded text-sky-400 flex items-center gap-2">
              <span className="text-sky-400">$</span> Dev Build
            </span>
          </div>
          
          <div className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden relative group shadow-lg">
            <div className="absolute top-0 left-0 w-1 h-full bg-sky-500"></div>
            <div className="flex items-center justify-between gap-4 p-4">
              <code className="font-mono text-sm md:text-base text-slate-300 break-all leading-relaxed">
                <span className="text-pink-400">loadstring</span><span className="text-slate-300">(</span><span className="text-sky-400">game:HttpGet(</span><span className="text-emerald-400">"{appUrl}/nex.lua"</span><span className="text-sky-400">)</span><span className="text-slate-300">)()</span>
              </code>
              <button 
                onClick={() => handleCopy(loadstringCmd, setCopied)}
                className="shrink-0 px-3 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-300 rounded-md transition-colors border border-slate-700 flex items-center justify-center"
                title="Copy Loadstring"
              >
                {copied ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
              </button>
            </div>
          </div>
          <p className="text-sm text-slate-400 mt-3 max-w-2xl">
            Copy the script above and execute it in your preferred environment (Synapse, Krnl, etc.).
            This URL points to the live development version hosted right here.
          </p>
        </section>

        <div className="grid md:grid-cols-2 gap-6 mb-16">
          {/* GitHub Export Instructions */}
          <div className="bg-slate-900/40 border border-slate-800 rounded-xl p-5 flex flex-col">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-indigo-500/20 rounded-lg flex items-center justify-center shrink-0">
                <Github className="w-5 h-5 text-indigo-400" />
              </div>
              <h3 className="text-lg font-semibold text-white tracking-tight">Publish to GitHub</h3>
            </div>
            <p className="text-sm text-slate-500 mb-6 flex-grow leading-relaxed">
              Want to host this script permanently? You can export this entire project directly to GitHub. Once pushed, you can use the raw GitHub URL for your loadstring.
            </p>
            <ol className="space-y-3 text-xs text-slate-500 mb-2">
              <li className="flex gap-2">
                <span className="text-sky-400 font-bold">1.</span> 
                Click the Export menu (in the AI Studio header)
              </li>
              <li className="flex gap-2">
                <span className="text-sky-400 font-bold">2.</span> 
                Select "Export to GitHub" and follow the prompts
              </li>
              <li className="flex gap-2 items-center">
                <span className="text-sky-400 font-bold">3.</span> 
                Locate your <code className="bg-slate-800 px-1.5 py-0.5 rounded ml-1 text-slate-300">public/nex.lua</code> file in your new repo
              </li>
              <li className="flex gap-2">
                <span className="text-sky-400 font-bold">4.</span> 
                Click "Raw" and use that URL in your loadstring!
              </li>
            </ol>
          </div>

          {/* Example Usage */}
          <div className="bg-slate-900/40 border border-slate-800 rounded-xl p-5 flex flex-col">
             <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 bg-sky-500/20 rounded-lg flex items-center justify-center shrink-0">
                <Download className="w-5 h-5 text-sky-400" />
              </div>
              <h3 className="text-lg font-semibold text-white tracking-tight">Example Output</h3>
            </div>
            <p className="text-sm text-slate-500 mb-4 leading-relaxed flex-grow">
               Once executed, the script initializes the library. Here is an example of what your script could look like:
            </p>
            <div className="bg-slate-900 border border-slate-800 rounded-lg p-4 font-mono text-xs overflow-x-auto text-slate-300 leading-relaxed">
               <span className="text-pink-400">local</span> Nex = loadstring(...)()<br/><br/>
               <span className="text-pink-400">local</span> Window = Nex.CreateWindow(<span className="text-emerald-400">"My Hub"</span>)<br/><br/>
               Window.CreateLabel(<span className="text-emerald-400">"Main Settings"</span>)<br/>
               Window.CreateToggle(<span className="text-emerald-400">"Auto Farm"</span>, <span className="text-purple-400">false</span>, <span className="text-pink-400">function</span>(state)<br/>
               &nbsp;&nbsp;&nbsp;&nbsp;print(<span className="text-emerald-400">"Toggled:"</span>, state)<br/>
               <span className="text-pink-400">end</span>)<br/><br/>
               Window.CreateSlider(<span className="text-emerald-400">"WalkSpeed"</span>, <span className="text-purple-400">16</span>, <span className="text-purple-400">100</span>, <span className="text-purple-400">16</span>, <span className="text-pink-400">function</span>(val)<br/>
               &nbsp;&nbsp;&nbsp;&nbsp;print(<span className="text-emerald-400">"Speed:"</span>, val)<br/>
               <span className="text-pink-400">end</span>)<br/><br/>
               Window.CreateButton(<span className="text-emerald-400">"Kill All"</span>, <span className="text-pink-400">function</span>()<br/>
               &nbsp;&nbsp;&nbsp;&nbsp;print(<span className="text-emerald-400">"Executed"</span>)<br/>
               <span className="text-pink-400">end</span>)
            </div>
          </div>
        </div>

        {/* Source Code Viewer */}
        <section>
          <div className="flex items-center justify-between mb-4">
             <h2 className="text-xl font-semibold text-white tracking-tight">Source Code</h2>
             <button 
                onClick={() => handleCopy(luaCode, setCopiedRaw)}
                className="flex items-center gap-2 text-sm font-medium text-slate-400 hover:text-white transition-colors bg-slate-800 hover:bg-slate-700 px-3 py-1.5 rounded-md border border-slate-700"
              >
                {copiedRaw ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
                {copiedRaw ? 'Copied' : 'Copy Source'}
              </button>
          </div>
          <div className="bg-slate-900 rounded-xl border border-slate-800 overflow-hidden relative shadow-lg">
            <div className="flex items-center justify-between px-4 py-2 bg-slate-800/50 border-b border-slate-700">
                <div className="flex gap-1.5">
                    <div className="w-2.5 h-2.5 rounded-full bg-red-500/50"></div>
                    <div className="w-2.5 h-2.5 rounded-full bg-amber-500/50"></div>
                    <div className="w-2.5 h-2.5 rounded-full bg-green-500/50"></div>
                </div>
                <span className="text-[10px] font-mono text-slate-500 uppercase tracking-wider">public/nex.lua</span>
            </div>
            <pre className="p-6 overflow-x-auto text-sm font-mono leading-relaxed text-slate-300 h-96">
                <code>{luaCode || "-- Loading source code..."}</code>
            </pre>
          </div>
        </section>
      </div>
    </div>
  );
}
