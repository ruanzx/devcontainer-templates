#!/bin/bash

# tldr Examples Script
# This script demonstrates various tldr commands and their usage

echo "🚀 tldr Examples - Simplified Man Pages"
echo "========================================"
echo ""

echo "📁 File Operations:"
echo "-------------------"
tldr ls
echo ""
tldr cp
echo ""
tldr mv
echo ""

echo "🔍 Text Processing:"
echo "-------------------"
tldr grep
echo ""
tldr sed
echo ""
tldr awk
echo ""

echo "🌐 Network Tools:"
echo "-----------------"
tldr curl
echo ""
tldr wget
echo ""
tldr ping
echo ""

echo "🐳 Development Tools:"
echo "---------------------"
tldr git
echo ""
tldr docker
echo ""
tldr npm
echo ""

echo "⚙️  System Administration:"
echo "-------------------------"
tldr ps
echo ""
tldr top
echo ""
tldr df
echo ""

echo "💡 Tip: Use 'tldr --list' to see all available pages"
echo "💡 Tip: Use 'tldr --update' to refresh the local cache"
echo "💡 Tip: Use 'docker volume rm tldr-cache' to force cache reset"