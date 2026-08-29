import { useState } from "react";

const BUTTONS = [
  { label: "C",   type: "clear"    },
  { label: "±",   type: "toggle"   },
  { label: "%",   type: "percent"  },
  { label: "÷",   type: "operator" },
  { label: "7",   type: "digit"    },
  { label: "8",   type: "digit"    },
  { label: "9",   type: "digit"    },
  { label: "×",   type: "operator" },
  { label: "4",   type: "digit"    },
  { label: "5",   type: "digit"    },
  { label: "6",   type: "digit"    },
  { label: "−",   type: "operator" },
  { label: "1",   type: "digit"    },
  { label: "2",   type: "digit"    },
  { label: "3",   type: "digit"    },
  { label: "+",   type: "operator" },
  { label: "⌫",   type: "back"     },
  { label: "0",   type: "digit"    },
  { label: ".",   type: "decimal"  },
  { label: "=",   type: "equals"   },
];

function evaluate(expr) {
  try {
    const sanitized = expr
      .replace(/×/g, "*")
      .replace(/÷/g, "/")
      .replace(/−/g, "-");
    // eslint-disable-next-line no-new-func
    const result = Function('"use strict"; return (' + sanitized + ')')();
    if (!isFinite(result)) return "Error";
    const rounded = parseFloat(result.toPrecision(12));
    return String(rounded);
  } catch {
    return "Error";
  }
}

export default function HomeScreen() {
  const [expr, setExpr]       = useState("");
  const [preview, setPreview] = useState("");
  const [justEvaled, setJustEvaled] = useState(false);

  const operators = ["+", "−", "×", "÷"];

  function getPreview(e) {
    if (!e || operators.some(op => e.endsWith(op)) || e.endsWith(".")) return "";
    const res = evaluate(e);
    return res === e ? "" : res;
  }

  function handleButton(label, type) {
    if (type === "clear") {
      setExpr("");
      setPreview("");
      setJustEvaled(false);
      return;
    }

    if (type === "back") {
      const next = expr.slice(0, -1);
      setExpr(next);
      setPreview(getPreview(next));
      setJustEvaled(false);
      return;
    }

    if (type === "equals") {
      if (!expr) return;
      const result = evaluate(expr);
      setExpr(result);
      setPreview("");
      setJustEvaled(true);
      return;
    }

    if (type === "toggle") {
      if (!expr) return;
      if (expr.startsWith("-")) {
        const next = expr.slice(1);
        setExpr(next);
        setPreview(getPreview(next));
      } else {
        const next = "-" + expr;
        setExpr(next);
        setPreview(getPreview(next));
      }
      return;
    }

    if (type === "percent") {
      if (!expr) return;
      const res = evaluate(expr + "/100");
      setExpr(res);
      setPreview("");
      setJustEvaled(true);
      return;
    }

    if (type === "operator") {
      if (!expr && label !== "−") return;
      // If last char is already an operator, replace it
      if (operators.some(op => expr.endsWith(op))) {
        const next = expr.slice(0, -1) + label;
        setExpr(next);
        setPreview("");
        setJustEvaled(false);
        return;
      }
      // If just evaluated, continue from result
      const next = expr + label;
      setExpr(next);
      setPreview("");
      setJustEvaled(false);
      return;
    }

    if (type === "decimal") {
      // Find the last number segment
      const parts = expr.split(/[+\-×÷]/);
      const lastPart = parts[parts.length - 1];
      if (lastPart.includes(".")) return;
      const next = (expr === "" ? "0." : expr + ".");
      setExpr(next);
      setPreview(getPreview(next));
      setJustEvaled(false);
      return;
    }

    if (type === "digit") {
      let next;
      if (justEvaled) {
        next = label;
        setJustEvaled(false);
      } else {
        next = expr + label;
      }
      setExpr(next);
      setPreview(getPreview(next));
      return;
    }
  }

  function btnStyle(type, label) {
    const base = {
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      borderRadius: 20,
      border: "none",
      cursor: "pointer",
      fontSize: 26,
      fontWeight: 600,
      height: 76,
      transition: "opacity 0.1s",
      userSelect: "none",
      WebkitTapHighlightColor: "transparent",
    };

    if (type === "equals") {
      return { ...base, background: "#6366f1", color: "#fff", fontSize: 30 };
    }
    if (type === "operator") {
      return { ...base, background: "#4f46e5", color: "#e0e7ff", fontSize: 28 };
    }
    if (type === "clear") {
      return { ...base, background: "#374151", color: "#f87171", fontWeight: 700 };
    }
    if (type === "back") {
      return { ...base, background: "#374151", color: "#a5b4fc" };
    }
    if (type === "toggle" || type === "percent") {
      return { ...base, background: "#374151", color: "#c4b5fd" };
    }
    // digit / decimal
    return { ...base, background: "#1f2937", color: "#f9fafb" };
  }

  const displayFontSize = expr.length > 14 ? 28 : expr.length > 10 ? 36 : 48;

  return (
    <div style={{
      minHeight: "100vh",
      width: "100%",
      background: "#111827",
      display: "flex",
      flexDirection: "column",
      justifyContent: "flex-end",
      padding: "0 16px 32px",
      boxSizing: "border-box",
    }}>
      {/* Display */}
      <div style={{
        flex: 1,
        display: "flex",
        flexDirection: "column",
        justifyContent: "flex-end",
        alignItems: "flex-end",
        padding: "32px 8px 24px",
        minHeight: 180,
      }}>
        {/* Preview / sub-expression */}
        <div style={{
          fontSize: 20,
          color: "#6b7280",
          minHeight: 28,
          marginBottom: 6,
          wordBreak: "break-all",
          textAlign: "right",
          maxWidth: "100%",
        }}>
          {preview && preview !== expr ? preview : ""}
        </div>

        {/* Main expression */}
        <div style={{
          fontSize: displayFontSize,
          fontWeight: 300,
          color: expr === "Error" ? "#f87171" : "#f9fafb",
          wordBreak: "break-all",
          textAlign: "right",
          maxWidth: "100%",
          lineHeight: 1.15,
          letterSpacing: -1,
          minHeight: 60,
        }}>
          {expr || "0"}
        </div>
      </div>

      {/* Divider */}
      <div style={{ height: 1, background: "#1f2937", marginBottom: 20 }} />

      {/* Button grid */}
      <div style={{
        display: "grid",
        gridTemplateColumns: "repeat(4, 1fr)",
        gap: 12,
      }}>
        {BUTTONS.map(({ label, type }) => (
          <button
            key={label}
            style={btnStyle(type, label)}
            onPointerDown={() => handleButton(label, type)}
          >
            {label}
          </button>
        ))}
      </div>
    </div>
  );
}
