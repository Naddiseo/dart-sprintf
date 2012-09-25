#import('../../../dart/dart-sdk/pkg/unittest/unittest.dart');
#import('../lib/sprintf.dart');

main() {
  
  group('Simple Int Formatting', () {
    test('int 1', () { expect(sprintf('!%d!', [42]), '!42!'); });
    test('int 2', () { expect(sprintf('!%i!', [42]), '!42!'); });
    test('int 3', () { expect(sprintf('!%d!', [0]), '!0!'); });
    test('int 4', () { expect(sprintf('!%i!', [0]), '!0!'); });
    test('int 5', () { expect(sprintf('!%d!', [-42]), '!-42!'); });
    test('int 6', () { expect(sprintf('!%i!', [-42]), '!-42!'); });
  });
  
  group('Int Force prefix Formatting', () {
    test('int 1', () { expect(sprintf('!%+d!', [42]), '!+42!'); });
    test('int 2', () { expect(sprintf('!%+i!', [42]), '!+42!'); });
    test('int 3', () { expect(sprintf('!%+d!', [0]), '!+0!'); });
    test('int 4', () { expect(sprintf('!%+i!', [0]), '!+0!'); });
    test('int 5', () { expect(sprintf('!%+d!', [-42]), '!-42!'); });
    test('int 6', () { expect(sprintf('!%+i!', [-42]), '!-42!'); });
  });
  
  group('Int add space Formatting', () {
    test('int 1', () { expect(sprintf('!% d!', [42]), '! 42!'); });
    test('int 2', () { expect(sprintf('!% i!', [42]), '! 42!'); });
    test('int 3', () { expect(sprintf('!% d!', [0]), '! 0!'); });
    test('int 4', () { expect(sprintf('!% i!', [0]), '! 0!'); });
    test('int 5', () { expect(sprintf('!% d!', [-42]), '! -42!'); });
    test('int 6', () { expect(sprintf('!% i!', [-42]), '! -42!'); });
  });
  
  group('Int Width Formatting', () {
    test('int 1', () { expect(sprintf('!%4d!', [42]), '!  42!'); });
    test('int 2', () { expect(sprintf('!%4i!', [42]), '!  42!'); });
    test('int 3', () { expect(sprintf('!%4d!', [0]), '!   0!'); });
    test('int 4', () { expect(sprintf('!%4i!', [0]), '!   0!'); });
    test('int 5', () { expect(sprintf('!%4d!', [-42]), '! -42!'); });
    test('int 6', () { expect(sprintf('!%4i!', [-42]), '! -42!'); });
  });
  
  group('Int Width zero padding Formatting', () {
    test('int 1', () { expect(sprintf('!%04d!', [42]), '!0042!'); });
    test('int 2', () { expect(sprintf('!%04i!', [42]), '!0042!'); });
    test('int 3', () { expect(sprintf('!%04d!', [0]), '!0000!'); });
    test('int 4', () { expect(sprintf('!%04i!', [0]), '!0000!'); });
    test('int 5', () { expect(sprintf('!%04d!', [-42]), '!-042!'); });
    test('int 6', () { expect(sprintf('!%04i!', [-42]), '!-042!'); });
  });
}