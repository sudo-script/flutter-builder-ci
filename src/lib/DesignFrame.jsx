import { useEffect, useLayoutEffect, useRef, useState } from 'react';

const DESIGN_WIDTH = 390;

/**
 * Scale a fixed-width design to the device viewport.
 *
 * @param {object} props
 * @param {number} [props.width]  design width in dp (default 390)
 * @param {number} [props.height] design height in dp
 * @param {boolean} [props.scroll] allow vertical scrolling when the scaled
 *   design is taller than the viewport
 * @param {string} [props.background]
 */
export default function DesignFrame({
  width = DESIGN_WIDTH,
  height = 844,
  scroll = true,
  background = 'var(--app-bg)',
  children,
}) {
  const hostRef = useRef(null);
  const [scale, setScale] = useState(1);

  useLayoutEffect(() => {
    const el = hostRef.current;
    if (!el) return undefined;
    const measure = () => {
      const available = el.clientWidth || width;
      setScale(available / width);
    };
    measure();
    if (typeof ResizeObserver === 'undefined') {
      window.addEventListener('resize', measure);
      return () => window.removeEventListener('resize', measure);
    }
    const ro = new ResizeObserver(measure);
    ro.observe(el);
    return () => ro.disconnect();
  }, [width]);

  return (
    <div
      ref={hostRef}
      style={{
        width: '100%',
        height: '100%',
        background,
        overflowX: 'hidden',
        overflowY: scroll ? 'auto' : 'hidden',
        WebkitOverflowScrolling: 'touch',
      }}
    >
      <div style={{ position: 'relative', width: '100%', height: height * scale }}>
        <div
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            width,
            height,
            transform: `scale(${scale})`,
            transformOrigin: 'top left',
          }}
        >
          {children}
        </div>
      </div>
    </div>
  );
}

/** Horizontal pager used by screens with scrollType "paged". */
export function PagedFrame({ pages = [], showIndicator = true, height = 844 }) {
  const trackRef = useRef(null);
  const [page, setPage] = useState(0);

  useEffect(() => {
    const el = trackRef.current;
    if (!el) return undefined;
    const onScroll = () => {
      const w = el.clientWidth || 1;
      setPage(Math.round(el.scrollLeft / w));
    };
    el.addEventListener('scroll', onScroll, { passive: true });
    return () => el.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>
      <div
        ref={trackRef}
        style={{
          display: 'flex',
          width: '100%',
          height: '100%',
          overflowX: 'auto',
          scrollSnapType: 'x mandatory',
          scrollbarWidth: 'none',
        }}
      >
        {pages.map((content, i) => (
          <div
            key={i}
            style={{ flex: '0 0 100%', scrollSnapAlign: 'start', height: '100%' }}
          >
            <DesignFrame height={height}>{content}</DesignFrame>
          </div>
        ))}
      </div>
      {showIndicator && pages.length > 1 && (
        <div
          style={{
            position: 'absolute',
            bottom: 16,
            left: 0,
            right: 0,
            display: 'flex',
            justifyContent: 'center',
            gap: 6,
          }}
        >
          {pages.map((_, i) => (
            <span
              key={i}
              style={{
                width: 7,
                height: 7,
                borderRadius: 999,
                background: i === page ? 'var(--app-accent)' : 'rgba(15,23,42,0.25)',
              }}
            />
          ))}
        </div>
      )}
    </div>
  );
}
