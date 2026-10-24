import ast
import unittest
from pathlib import Path


class TestLambdaSource(unittest.TestCase):
    def test_python_syntax_and_handler(self):
        source = Path(__file__).resolve().parents[1] / 'app' / 'index.py'
        tree = ast.parse(source.read_text(encoding='utf-8'))
        handlers = [
            node for node in tree.body
            if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
            and node.name == 'handler'
        ]
        self.assertEqual(len(handlers), 1, 'Expected one Lambda handler')
        self.assertEqual(
            [arg.arg for arg in handlers[0].args.args],
            ['event', 'context']
        )


if __name__ == '__main__':
    unittest.main()
