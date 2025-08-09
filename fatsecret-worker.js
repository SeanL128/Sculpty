addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request))
})

async function handleRequest(request) {
  const corsResponse = handleCors(request)
  if (corsResponse) return corsResponse
  
  const url = new URL(request.url)
  const path = url.pathname
  
  try {
    if (path === '/') {
      return await handleRoot()
    } else if (path === '/health') {
      return await handleHealth()
    } else if (path === '/search') {
      return await handleSearch(request)
    } else if (path.startsWith('/food/')) {
      return await handleFoodDetails(request)
    } else if (path.startsWith('/barcode/')) {
      return await handleBarcode(request)
    } else {
      return setCorsHeaders(new Response(JSON.stringify({ 
        error: 'Not found' 
      }), { 
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      }))
    }
  } catch (error) {
    console.error('Worker error:', error)
    return setCorsHeaders(new Response(JSON.stringify({ 
      error: 'Internal server error',
      message: error.message 
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    }))
  }
}

async function getFatSecretToken() {
  const clientId = FATSECRET_CLIENT_ID
  const clientSecret = FATSECRET_CLIENT_SECRET
  
  if (!clientId || !clientSecret) {
    throw new Error('FatSecret credentials not configured')
  }
  
  const credentials = btoa(`${clientId}:${clientSecret}`)
  
  try {
    const response = await fetch('https://oauth.fatsecret.com/connect/token', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: 'grant_type=client_credentials&scope=premier barcode'
    })
    
    if (!response.ok) {
      throw new Error(`Token request failed: ${response.status}`)
    }
    
    const data = await response.json()
    return data.access_token
  } catch (error) {
    console.error('Error getting FatSecret token:', error)
    throw error
  }
}

function setCorsHeaders(response) {
  response.headers.set('Access-Control-Allow-Origin', '*')
  response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
  response.headers.set('Access-Control-Allow-Headers', 'Content-Type')
  return response
}

function handleCors(request) {
  if (request.method === 'OPTIONS') {
    return setCorsHeaders(new Response(null, { status: 200 }))
  }
  return null
}

function processServings(foodData) {
  if (foodData.food && foodData.food.servings && foodData.food.servings.serving) {
    if (!Array.isArray(foodData.food.servings.serving)) {
      foodData.food.servings.serving = [foodData.food.servings.serving]
    }
    
    if (foodData.food.servings.serving.length > 0) {
      let baseServing = foodData.food.servings.serving.find(serving => 
        serving.metric_serving_amount && 
        parseFloat(serving.metric_serving_amount) > 0 &&
        ['g', 'oz', 'ml'].includes(serving.metric_serving_unit)
      ) || foodData.food.servings.serving[0]
      
      const servingAmount = parseFloat(baseServing.metric_serving_amount) || 100
      const unit = baseServing.metric_serving_unit
      
      const newServings = []
      
      if (unit === 'g' || unit === 'oz') {
        let gramsAmount = servingAmount
        if (unit === 'oz') {
          gramsAmount = servingAmount * 28.3495
        }
        
        newServings.push({
          serving_description: "g",
          measurement_description: "g", 
          metric_serving_amount: "1.000",
          metric_serving_unit: "g",
          calories: baseServing.calories ? String((parseFloat(baseServing.calories) / servingAmount).toFixed(3)) : null,
          protein: baseServing.protein ? String((parseFloat(baseServing.protein) / servingAmount).toFixed(3)) : null,
          fat: baseServing.fat ? String((parseFloat(baseServing.fat) / servingAmount).toFixed(3)) : null,
          carbohydrate: baseServing.carbohydrate ? String((parseFloat(baseServing.carbohydrate) / servingAmount).toFixed(3)) : null,
        })
      } else if (unit === 'ml') {
        newServings.push({
          serving_description: "ml",
          measurement_description: "ml",
          metric_serving_amount: "1.000",
          metric_serving_unit: "ml", 
          calories: baseServing.calories ? String((parseFloat(baseServing.calories) / servingAmount).toFixed(3)) : null,
          protein: baseServing.protein ? String((parseFloat(baseServing.protein) / servingAmount).toFixed(3)) : null,
          fat: baseServing.fat ? String((parseFloat(baseServing.fat) / servingAmount).toFixed(3)) : null,
          carbohydrate: baseServing.carbohydrate ? String((parseFloat(baseServing.carbohydrate) / servingAmount).toFixed(3)) : null,
        })
      }
      
      foodData.food.servings.serving.push(...newServings)
      console.log(`Added ${newServings.length} per-unit serving(s)`)
    }
  }
  
  return foodData
}

async function handleSearch(request) {
  const url = new URL(request.url)
  const query = url.searchParams.get('q')
  
  if (!query) {
    return setCorsHeaders(new Response(JSON.stringify({ 
      error: 'Missing search query. Use ?q=chicken' 
    }), { 
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    }))
  }
  
  try {
    console.log(`Searching for: ${query}`)
    
    const token = await getFatSecretToken()
    
    const searchUrl = `https://platform.fatsecret.com/rest/server.api?method=foods.search&search_expression=${encodeURIComponent(query)}&format=json`
    
    const response = await fetch(searchUrl, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!response.ok) {
      throw new Error(`FatSecret API error: ${response.status}`)
    }
    
    const data = await response.json()
    console.log(`Found ${data.foods?.food?.length || 0} results for "${query}"`)
    
    return setCorsHeaders(new Response(JSON.stringify(data), {
      headers: { 'Content-Type': 'application/json' }
    }))
  } catch (error) {
    console.error('Search error:', error)
    return setCorsHeaders(new Response(JSON.stringify({ 
      error: 'Search failed',
      message: error.message 
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    }))
  }
}

async function handleFoodDetails(request) {
  const url = new URL(request.url)
  const pathParts = url.pathname.split('/')
  const foodId = pathParts[2]
  
  try {
    console.log(`Getting details for food ID: ${foodId}`)
    
    const token = await getFatSecretToken()
    
    const detailUrl = `https://platform.fatsecret.com/rest/server.api?method=food.get&food_id=${foodId}&format=json`
    
    const response = await fetch(detailUrl, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!response.ok) {
      throw new Error(`FatSecret API error: ${response.status}`)
    }
    
    const data = await response.json()
    const processedData = processServings(data)
    
    return setCorsHeaders(new Response(JSON.stringify(processedData), {
      headers: { 'Content-Type': 'application/json' }
    }))
  } catch (error) {
    console.error('Food details error:', error)
    return setCorsHeaders(new Response(JSON.stringify({ 
      error: 'Failed to get food details',
      message: error.message 
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    }))
  }
}

async function handleBarcode(request) {
  const url = new URL(request.url)
  const pathParts = url.pathname.split('/')
  const barcode = pathParts[2]
  
  if (!barcode) {
    return setCorsHeaders(new Response(JSON.stringify({ 
      error: 'Missing barcode parameter' 
    }), { 
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    }))
  }
  
  try {
    console.log(`Looking up barcode: ${barcode}`)
    
    const token = await getFatSecretToken()
    
    const barcodeUrl = `https://platform.fatsecret.com/rest/server.api?method=food.find_id_for_barcode&barcode=${barcode}&format=json`
    
    const barcodeResponse = await fetch(barcodeUrl, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!barcodeResponse.ok) {
      if (barcodeResponse.status === 404) {
        return setCorsHeaders(new Response(JSON.stringify({ 
          error: 'Barcode not found',
          message: 'This barcode is not in our database' 
        }), { 
          status: 404,
          headers: { 'Content-Type': 'application/json' }
        }))
      }
      throw new Error(`FatSecret barcode API error: ${barcodeResponse.status}`)
    }
    
    const barcodeData = await barcodeResponse.json()
    const foodId = barcodeData.food_id?.value
    
    if (!foodId) {
      return setCorsHeaders(new Response(JSON.stringify({ 
        error: 'Barcode not found',
        message: 'This barcode is not in our database' 
      }), { 
        status: 404,
        headers: { 'Content-Type': 'application/json' }
      }))
    }
    
    console.log(`Found food_id ${foodId} for barcode ${barcode}`)
    
    const detailUrl = `https://platform.fatsecret.com/rest/server.api?method=food.get&food_id=${foodId}&format=json`
    
    const detailResponse = await fetch(detailUrl, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!detailResponse.ok) {
      throw new Error(`FatSecret food detail API error: ${detailResponse.status}`)
    }
    
    const foodData = await detailResponse.json()
    const processedFoodData = processServings(foodData)
    
    const result = {
      food_id: processedFoodData.food.food_id,
      food_name: processedFoodData.food.food_name,
      food_type: processedFoodData.food.food_type,
      brand_name: processedFoodData.food.brand_name || null,
      food_description: null,
      food_url: processedFoodData.food.food_url || null,
      detail: processedFoodData.food
    }
    
    return setCorsHeaders(new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' }
    }))
  } catch (error) {
    console.error('Barcode lookup error:', error)
    return setCorsHeaders(new Response(JSON.stringify({ 
      error: 'Barcode lookup failed',
      message: error.message 
    }), { 
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    }))
  }
}

async function handleHealth() {
  return setCorsHeaders(new Response(JSON.stringify({ 
    status: 'healthy',
    fatSecretConfigured: !!(FATSECRET_CLIENT_ID && FATSECRET_CLIENT_SECRET)
  }), {
    headers: { 'Content-Type': 'application/json' }
  }))
}

async function handleRoot() {
  return setCorsHeaders(new Response(JSON.stringify({ 
    message: 'FatSecret Proxy Server is running!',
    status: 'ready'
  }), {
    headers: { 'Content-Type': 'application/json' }
  }))
}
