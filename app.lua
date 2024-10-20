local telegram = require('telegram-bot-lua')
local http = require('socket.http')

local AppToken = '7646877814:AAFx-LjNMqIqzLs-30pTwM_vVrV0w5DHDLA'
local bot = telegram.new(AppToken)

local MATRIX_START_TEXT = [[
Want to know how cool your Telegram presence is? 
Check your profile rating and unlock awesome rewards with $MTRX Matrix AI!

Time to vibe ✨ and step into the world of Web3.
$MTRX is on the way... Ready to explore something new?

Take the first step and see just how you stack up!
]]

local function getUsername(userId)
    local response = bot:getChat(userId)
    if response.result.username then
        return "@" .. response.result.username
    else
        return response.result.first_name
    end
end

bot.command('exec', function(msg)
    local chatId = msg.chat.id
    local userId = msg.from.id
    local command = msg.text:match("^/exec%s*(.*)")
    
    if command == "" then
        bot:sendMessage(chatId, 'No input found!')
        return
    end
    
    bot:sendMessage(chatId, '`Processing...`', 'Markdown')
    
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()

    local response = result ~= "" and "<code>" .. result .. "</code>" or "No output from command"
    bot:sendMessage(chatId, response, 'HTML')
end)

bot.command('start', function(msg)
    local chatId = msg.chat.id
    local userId = msg.from.id
    local commandArgs = msg.text:match("^/start%s*(.*)")
    
    if commandArgs and commandArgs:find('ref_') then
        local inviterId = commandArgs:match('ref_(%d+)')
        local inviterName = getUsername(inviterId)

        local messageText = MATRIX_START_TEXT .. "\nInvited by: " .. inviterName
        local inlineKeyboard = {
            inline_keyboard = {
                {{ text = "Play Now 🪂", url = "https://mtx-ai-bot.vercel.app/?userId=" .. userId .. "&inviterId=" .. inviterId }},
                {{ text = "Join Community 🔥", url = "https://telegram.me/MatrixAi_Ann" }}
            }
        }

        bot:sendPhoto(chatId, "https://i.ibb.co/XDPzBWc/pngtree-virtual-panel-generate-ai-image-15868619.jpg", messageText, inlineKeyboard)
        bot:sendMessage(inviterId, (msg.from.username or msg.from.first_name) .. " Joined via your invite link!")
    else
        local inlineKeyboard = {
            inline_keyboard = {
                {{ text = "Play Now 🪂", url = "https://mtx-ai-bot.vercel.app/?userId=" .. userId }},
                {{ text = "Join Community 🔥", url = "https://telegram.me/MatrixAi_Ann" }}
            }
        }

        bot:sendPhoto(chatId, "https://i.ibb.co/XDPzBWc/pngtree-virtual-panel-generate-ai-image-15868619.jpg", MATRIX_START_TEXT, inlineKeyboard)
    end
end)

bot.command('referrals', function(msg)
    local chatId = msg.chat.id
    local referralLink = "https://telegram.me/MTRXAi_Bot?start=ref_" .. msg.from.id
    bot:sendMessage(chatId, "Here is your referral link: " .. referralLink)
end)

bot.command('id', function(msg)
    if msg.reply_to_message then
        bot:sendMessage(msg.chat.id, msg.reply_to_message.from.first_name .. "'s ID: `" .. msg.reply_to_message.from.id .. "`", 'Markdown')
    else
        bot:sendMessage(msg.chat.id, msg.from.first_name .. "'s ID: `" .. msg.from.id .. "`", 'Markdown')
    end
end)

bot:run()
