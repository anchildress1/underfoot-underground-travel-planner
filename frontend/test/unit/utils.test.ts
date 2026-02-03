import { describe, it, expect } from 'vitest';
import { cn, formatTimestamp, generateId, pluralize } from '../../src/utils';

describe('Utils', () => {
  describe('cn', () => {
    it('should combine class names', () => {
      expect(cn('foo', 'bar')).toBe('foo bar');
    });

    it('should handle conditional classes', () => {
      // eslint-disable-next-line no-constant-binary-expression
      expect(cn('foo', false && 'bar', 'baz')).toBe('foo baz');
    });

    it('should handle null and undefined', () => {
      expect(cn('foo', null, undefined, 'bar')).toBe('foo bar');
    });

    it('should handle arrays', () => {
      expect(cn(['foo', 'bar'], 'baz')).toBe('foo bar baz');
    });

    it('should handle objects', () => {
      expect(cn({ foo: true, bar: false, baz: true })).toBe('foo baz');
    });

    it('should handle mixed inputs', () => {
      expect(cn('foo', ['bar', { baz: true, qux: false }], null, 'quux')).toBe('foo bar baz quux');
    });
  });

  describe('formatTimestamp', () => {
    it('should format date to HH:MM', () => {
      const date = new Date('2024-01-15T14:30:00');
      expect(formatTimestamp(date)).toMatch(/^\d{2}:\d{2}$/);
    });

    it('should handle midnight', () => {
      const date = new Date('2024-01-15T00:00:00');
      const formatted = formatTimestamp(date);
      expect(formatted).toMatch(/^\d{2}:\d{2}$/);
    });

    it('should handle noon', () => {
      const date = new Date('2024-01-15T12:00:00');
      const formatted = formatTimestamp(date);
      expect(formatted).toMatch(/^\d{2}:\d{2}$/);
    });

    it('should pad single digits', () => {
      const date = new Date('2024-01-15T09:05:00');
      const formatted = formatTimestamp(date);
      expect(formatted).toMatch(/^\d{2}:\d{2}$/);
    });
  });

  describe('generateId', () => {
    it('should generate unique IDs', () => {
      const id1 = generateId();
      const id2 = generateId();
      expect(id1).not.toBe(id2);
    });

    it('should generate string IDs', () => {
      const id = generateId();
      expect(typeof id).toBe('string');
    });

    it('should generate non-empty IDs', () => {
      const id = generateId();
      expect(id.length).toBeGreaterThan(0);
    });

    it('should generate different IDs in rapid succession', () => {
      const ids = Array.from({ length: 100 }, () => generateId());
      const uniqueIds = new Set(ids);
      expect(uniqueIds.size).toBe(100);
    });
  });

  describe('pluralize', () => {
    it('should return singular for count of 1', () => {
      expect(pluralize(1, 'item')).toBe('item');
    });

    it('should return plural for count of 0', () => {
      expect(pluralize(0, 'item')).toBe('items');
    });

    it('should return plural for count greater than 1', () => {
      expect(pluralize(5, 'item')).toBe('items');
    });

    it('should use custom plural when provided', () => {
      expect(pluralize(0, 'person', 'people')).toBe('people');
      expect(pluralize(2, 'person', 'people')).toBe('people');
    });

    it('should use singular when count is 1 even with custom plural', () => {
      expect(pluralize(1, 'person', 'people')).toBe('person');
    });
  });
});
